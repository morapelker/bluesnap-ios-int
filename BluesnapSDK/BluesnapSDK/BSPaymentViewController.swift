//
//  BSPaymentViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 21/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSPaymentViewController: UIViewController, UITextFieldDelegate, BSCcInputLineDelegate {

    // MARK: - Public properties
    
    internal var paymentDetails : BSPaymentDetails!
    internal var fullBilling = false
    internal var bsToken: BSToken!
    internal var purchaseFunc: (BSPaymentDetails!)->Void = {
        paymentDetails in
        print("purchaseFunc should be overridden")
    }
    internal var countryManager = BSCountryManager()
    
    // MARK: private properties
    
    fileprivate var withShipping = false
    fileprivate var shippingScreen: BSShippingViewController!
    fileprivate var cardType : String?
    fileprivate var activityIndicator : UIActivityIndicatorView?
    fileprivate var firstTime : Bool! = true
    fileprivate var payButtonText : String?
    fileprivate var zipTopConstraintOriginalConstant : CGFloat?
    
    // MARK: - Outlets
    
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var subtotalUILabel: UILabel!
    @IBOutlet weak var taxAmountUILabel: UILabel!
    @IBOutlet weak var taxDetailsView: UIView!
    
    @IBOutlet weak var ccInputLine: BSCcInputLine!
    
    @IBOutlet weak var nameInputLine: BSInputLine!
    @IBOutlet weak var emailInputLine: BSInputLine!
    @IBOutlet weak var streetInputLine: BSInputLine!
    @IBOutlet weak var zipInputLine: BSInputLine!
    @IBOutlet weak var cityInputLine: BSInputLine!
    @IBOutlet weak var stateInputLine: BSInputLine!
    
    @IBOutlet weak var shippingSameAsBillingView: UIView!
    @IBOutlet weak var shippingSameAsBillingSwitch: UISwitch!
    
    @IBOutlet weak var zipTopConstraint: NSLayoutConstraint!
    
    
    // MARK: for scrolling to prevent keyboard hiding
    
    let scrollOffset : Int = -64 // this is the Y of scrollView
    
    var movedUp = false
    var fieldBottom : Int?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fieldsView: UIView!
    
    override func viewDidLayoutSubviews()
    {
        let scrollViewBounds = scrollView.bounds
        //let containerViewBounds = fieldsView.bounds
        
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = scrollViewBounds.size.height/2.0;
        scrollViewInsets.top -= fieldsView.bounds.size.height/2.0;
        
        scrollViewInsets.bottom = scrollViewBounds.size.height/2.0
        scrollViewInsets.bottom -= fieldsView.bounds.size.height/2.0;
        scrollViewInsets.bottom += 1
        
        scrollView.contentInset = scrollViewInsets
    }
    
    @IBAction func editingDidBegin(_ sender: BSBaseInputControl) {
        
        fieldBottom = Int(sender.frame.origin.y + sender.frame.height)
    }
    
    private func scrollForKeyboard(direction: Int) {
        
        self.movedUp = (direction > 0)
        let y = 200*direction
        let point : CGPoint = CGPoint(x: 0, y: y)
        self.scrollView.setContentOffset(point, animated: false)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        var moveUp = false
        if let fieldBottom = fieldBottom {
            let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
            let keyboardFrame = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! CGRect
            let keyboardHeight = Int(keyboardFrame.height)
            let viewHeight : Int = Int(self.view.frame.height)
            let offset = fieldBottom + keyboardHeight - scrollOffset
            //print("fieldBottom:\(fieldBottom), keyboardHeight:\(keyboardHeight), offset:\(offset), viewHeight:\(viewHeight)")
            if (offset > viewHeight) {
                moveUp = true
            }
        }
        
        if !self.movedUp && moveUp {
            scrollForKeyboard(direction: 1)
        } else if self.movedUp && !moveUp {
            scrollForKeyboard(direction: 0)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if self.movedUp {
            scrollForKeyboard(direction: 0)
        }
    }
    
    // MARK: BSCcInputLineDelegate methods
    
    func willCheckCreditCard() {
        startActivityIndicator()
    }
    func didCheckCreditCard() {
        stopActivityIndicator()
    }
    
    func checkCreditCard(ccn: String, completion: @escaping (Bool) -> Void) {
        
        // get issuing country and card type from server
        var isOK = false
        
        BSApiManager.submitCcn(bsToken: bsToken, ccNumber: ccn, completion: { (result, error) in
            //Check for error
            if let error = error{
                if (error == BSCcDetailErrors.invalidCcNumber) {
                    self.ccInputLine.showError(BSValidator.ccnInvalidMessage)
                } else {
                    self.showAlert("An error occurred")
                }
                isOK = false
                completion(isOK)
            }
            
            // Check for result
            guard let result = result,
                let issuingCountry = result.ccIssuingCountry,
                let cardType = result.ccType
                else{
                    return
            }
            
            self.updateWithNewCountry(countryCode: issuingCountry, countryName: "")
            self.ccInputLine.cardType = cardType
            isOK = true
            completion(isOK)
            
        })
    }
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ccInputLine.delegate = self
        
        emailInputLine.fieldKeyboardType = .emailAddress
        activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        if let zipTopConstraint = self.zipTopConstraint {
            zipTopConstraintOriginalConstant = zipTopConstraint.constant
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.navigationController!.isNavigationBarHidden = false
        
        self.withShipping = paymentDetails.getShippingDetails() != nil
        
        shippingSameAsBillingView.isHidden = !self.withShipping || !self.fullBilling
        // set the "shipping same as billing" to be true if no shipping name is supplied
        shippingSameAsBillingSwitch.isOn = self.paymentDetails.getShippingDetails()?.name ?? "" == ""
        
        updateTexts()
        
        taxDetailsView.isHidden = self.paymentDetails.getTaxAmount() == 0
        
        ccInputLine.startEditCcFunc = startEditCcFunc
        ccInputLine.endEditCcFunc = endEditCcFunc
        
        if self.firstTime == true {
            self.firstTime = false
            if let billingDetails = paymentDetails.getBillingDetails() {
                self.nameInputLine.setValue(billingDetails.name)
                if fullBilling {
                    self.emailInputLine.setValue(billingDetails.email)
                    self.zipInputLine.setValue(billingDetails.zip)
                    self.streetInputLine.setValue(billingDetails.address)
                    self.cityInputLine.setValue(billingDetails.city)
                }
            }
            ccInputLine.ccnIsOpen = true
        }
        hideShowFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if ccInputLine.ccnIsOpen == true {
            self.ccInputLine.focusOnCcnField()
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        
        ccInputLine.closeOnLeave()
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    // MARK: private methods
    
    private func hideShowFields() {
        
        if self.ccInputLine.ccnIsOpen {
            // hide everything
            nameInputLine.isHidden = true
            emailInputLine.isHidden = true
            streetInputLine.isHidden = true
            cityInputLine.isHidden = true
            zipInputLine.isHidden = true
            stateInputLine.isHidden = true
            shippingSameAsBillingView.isHidden = true
            taxDetailsView.isHidden = true
        } else {
            nameInputLine.isHidden = false
            let hideFields = !self.fullBilling
            emailInputLine.isHidden = hideFields
            streetInputLine.isHidden = hideFields
            let countryCode = self.paymentDetails.getBillingDetails().country ?? ""
            updateZipByCountry(countryCode: countryCode)
            updateFlagImage(countryCode: countryCode)
            cityInputLine.isHidden = hideFields
            updateState()
            shippingSameAsBillingView.isHidden = !self.withShipping || !self.fullBilling
            taxDetailsView.isHidden = self.paymentDetails.taxAmount == 0
            if hideFields == false {
                zipTopConstraint.constant = zipTopConstraintOriginalConstant ?? 1
            } else {
                zipTopConstraint.constant = -1 * emailInputLine.frame.height
            }
        }
    }
    
    private func updateState() {
        
        if (fullBilling) {
            BSValidator.updateState(addressDetails: paymentDetails.getBillingDetails(), countryManager: countryManager, stateInputLine: stateInputLine)
        } else {
            stateInputLine.isHidden = true
        }
    }
    
    private func updateTexts() {
        
        let toCurrency = paymentDetails.getCurrency() ?? ""
        let subtotalAmount = paymentDetails.getAmount() ?? 0.0
        let taxAmount = (paymentDetails.getTaxAmount() ?? 0.0)
        let amount = subtotalAmount + taxAmount
        let currencyCode = (toCurrency == "USD" ? "$" : toCurrency)
        payButtonText = String(format:"Pay %@ %.2f", currencyCode, CGFloat(amount))
        updatePayButtonText()
        subtotalUILabel.text = String(format:" %@ %.2f", currencyCode, CGFloat(subtotalAmount))
        taxAmountUILabel.text = String(format:" %@ %.2f", currencyCode, CGFloat(taxAmount))
    }

    private func updatePayButtonText() {
        
        if (self.withShipping && !self.shippingSameAsBillingSwitch.isOn) {
            payButton.setTitle("Shipping >", for: UIControlState())
        } else {
            payButton.setTitle(payButtonText, for: UIControlState())
        }
    }
    
    private func submitPaymentFields() {
        
        startActivityIndicator()
        
        let ccn = self.ccInputLine.getValue() ?? ""
        let cvv = self.ccInputLine.getCvv() ?? ""
        let exp = self.ccInputLine.getExpDateAsMMYYYY() ?? ""

        BSApiManager.submitCcDetails(bsToken: self.bsToken, ccNumber: ccn, expDate: exp, cvv: cvv, completion: { (result, error) in
            
            self.stopActivityIndicator()
            
            //Check for error
            if let error = error{
                if (error == BSCcDetailErrors.invalidCcNumber) {
                    self.ccInputLine.showError(field: self.ccInputLine.textField, errorText: BSValidator.ccnInvalidMessage)
                } else if (error == BSCcDetailErrors.invalidExpDate) {
                    self.ccInputLine.showError(field: self.ccInputLine.expTextField, errorText: BSValidator.expInvalidMessage)
                } else if (error == BSCcDetailErrors.invalidCvv) {
                    self.ccInputLine.showError(field: self.ccInputLine.cvvTextField, errorText: BSValidator.cvvInvalidMessage)
                } else if (error == BSCcDetailErrors.expiredToken) {
                    self.showAlert("Your session has expired, please go back and try again")
                } else {
                    NSLog("Unexpected error submitting Payment Fields to BS")
                    self.showAlert("An error occurred, please try again")
                }
            }
            
            // Check for result
            if let result = result {
                self.paymentDetails.setCcDetails(ccDetails: result)
                // return to merchant screen
                if let navigationController = self.navigationController {
                    let viewControllers = navigationController.viewControllers
                    let merchantControllerIndex = viewControllers.count-3
                    _ = navigationController.popToViewController(viewControllers[merchantControllerIndex], animated: false)
                }
                // execute callback
                self.purchaseFunc(self.paymentDetails)
            }
        })
    }
    
    
    private func showAlert(_ message : String) {
        let alert = BSViewsManager.createErrorAlert(title: "Oops", message: message)
        present(alert, animated: true, completion: nil)
    }
    
    private func gotoShippingScreen() {
        
        if (self.shippingScreen == nil) {
            if let storyboard = storyboard {
                self.shippingScreen = storyboard.instantiateViewController(withIdentifier: "BSShippingDetailsScreen") as! BSShippingViewController
                self.shippingScreen.paymentDetails = self.paymentDetails
                self.shippingScreen.submitPaymentFields = submitPaymentFields
                self.shippingScreen.countryManager = self.countryManager
            }
        }
        self.shippingScreen.payText = self.payButtonText
        self.navigationController?.pushViewController(self.shippingScreen, animated: true)
    }
    
    
    private func updateWithNewCountry(countryCode : String, countryName : String) {
        
        paymentDetails.getBillingDetails().country = countryCode
        updateZipByCountry(countryCode: countryCode)
        updateState()
        
        // load the flag image
        updateFlagImage(countryCode: countryCode.uppercased())
    }

    private func updateZipByCountry(countryCode : String) {
        
        let hideZip = self.countryManager.countryHasNoZip(countryCode: countryCode)
        if countryCode.lowercased() == "us" {
            self.zipInputLine.labelText = "Billing Zip"
            self.zipInputLine.fieldKeyboardType = .numberPad
        } else {
            self.zipInputLine.labelText = "Postal Code"
            self.zipInputLine.fieldKeyboardType = .numbersAndPunctuation
        }
        self.zipInputLine.isHidden = hideZip
        self.zipInputLine.hideError(nil)
    }
    
    private func updateWithNewState(stateCode : String, stateName : String) {
        
        paymentDetails.getBillingDetails().state = stateCode
        self.stateInputLine.setValue(stateName)
    }
    
    private func updateFlagImage(countryCode : String) {
        
        // load the flag image
        if let image = BSViewsManager.getImage(imageName: countryCode.uppercased()) {
            nameInputLine.image = image
        }
    }

    
    // MARK: menu actions
    
    private func updateCurrencyFunc(oldCurrency : BSCurrency?, newCurrency : BSCurrency?) {
        
        paymentDetails.changeCurrency(oldCurrency: oldCurrency, newCurrency: newCurrency)
    }
    
    @IBAction func MenuClick(_ sender: UIBarButtonItem) {
        
        let menu : UIAlertController = BSViewsManager.openPopupMenu(paymentDetails: paymentDetails, bsToken: bsToken, inNavigationController: self.navigationController!, updateCurrencyFunc: updateCurrencyFunc)
        present(menu, animated: true, completion: nil)
    }
    
    // MARK: button actions
    
    @IBAction func shippingSameAsBillingValueChanged(_ sender: Any) {
        
        updatePayButtonText()
    }
    
    @IBAction func clickPay(_ sender: UIButton) {
        
        if (validateForm()) {
            
            if (withShipping && (!shippingSameAsBillingSwitch.isOn || shippingSameAsBillingSwitch.isHidden)) {
                gotoShippingScreen()
            } else {
                submitPaymentFields()
            }
        } else {
            //return false
        }
    }

    
    // MARK: Validation methods
    
    func validateForm() -> Bool {
        
        let ok1 = validateName(ignoreIfEmpty: false)
        let ok2 = ccInputLine.validate()
        var result = ok1 && ok2
        
        if fullBilling {
            let ok1 = validateEmail(ignoreIfEmpty: false)
            let ok2 = validateCity(ignoreIfEmpty: false)
            let ok3 = validateAddress(ignoreIfEmpty: false)
            let ok4 = validateCity(ignoreIfEmpty: false)
            let ok5 = validateZip(ignoreIfEmpty: false)
            let ok6 = validateState(ignoreIfEmpty: false)
            result = result && ok1 && ok2 && ok3 && ok4 && ok5 && ok6
        } else if !zipInputLine.isHidden {
            let ok = validateZip(ignoreIfEmpty: false)
            result = result && ok
        }
        
        if result && shippingSameAsBillingSwitch.isOn && !shippingSameAsBillingSwitch.isHidden {
            // copy billing details to shipping
            if let shippingDetails = self.paymentDetails.getShippingDetails(), let billingDetails = self.paymentDetails.getBillingDetails() {
                shippingDetails.address = billingDetails.address
                shippingDetails.city = billingDetails.city
                shippingDetails.country = billingDetails.country
                shippingDetails.email = billingDetails.email
                shippingDetails.name = billingDetails.name
                shippingDetails.state = billingDetails.state
                shippingDetails.zip = billingDetails.zip
            }
        }
        
        return result
    }
    
    func validateName(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateName(ignoreIfEmpty: ignoreIfEmpty, input: nameInputLine, addressDetails: paymentDetails.getBillingDetails())
        return result
    }
    
    func validateEmail(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateEmail(ignoreIfEmpty: ignoreIfEmpty, input: emailInputLine, addressDetails: paymentDetails.getBillingDetails())
        return result
    }
    
    func validateAddress(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateAddress(ignoreIfEmpty: ignoreIfEmpty, input: streetInputLine, addressDetails: paymentDetails.getBillingDetails())
        return result
    }
    
    func validateCity(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateCity(ignoreIfEmpty: ignoreIfEmpty, input: cityInputLine, addressDetails: paymentDetails.getBillingDetails())
        return result
    }

    func validateZip(ignoreIfEmpty : Bool) -> Bool {
        
        if (zipInputLine.isHidden) {
            paymentDetails.getBillingDetails().zip = ""
            zipInputLine.setValue("")
            return true
        }
        
        // make zip optional for cards other than visa/discover
        var ignoreEmptyZip = ignoreIfEmpty
        let ccType = self.ccInputLine.getCardType().lowercased()
        if !ignoreIfEmpty && !fullBilling && ccType != "visa" && ccType != "discover" {
            ignoreEmptyZip = true
        }
        
        let result = BSValidator.validateZip(ignoreIfEmpty: ignoreEmptyZip, input: zipInputLine, addressDetails: paymentDetails.getBillingDetails())
        return result
    }
    
    func validateState(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateState(ignoreIfEmpty: ignoreIfEmpty, input: stateInputLine, addressDetails: paymentDetails.getBillingDetails())
        return result
    }

    // MARK: CC details additions
    
    internal func resetCC() {
        ccInputLine.reset()
    }
    
    func startActivityIndicator() {
        BSViewsManager.startActivityIndicator(activityIndicator: self.activityIndicator)
    }
    func stopActivityIndicator() {
        BSViewsManager.stopActivityIndicator(activityIndicator: self.activityIndicator)
    }

    internal func startEditCcFunc() {
        hideShowFields()
    }
    
    internal func endEditCcFunc() {
        hideShowFields()
    }

    
    // MARK: real-time formatting and Validations on text fields
    
    @IBAction func nameEditingChanged(_ sender: BSInputLine) {
        
        BSValidator.nameEditingChanged(sender)
    }
    
    @IBAction func nameEditingDidEnd(_ sender: BSInputLine) {
        _ = validateName(ignoreIfEmpty: true)
    }

    @IBAction func countryFlagClick(_ sender: BSInputLine) {
        
        // open the country screen
        let selectedCountryCode = paymentDetails.getBillingDetails().country ?? ""
        BSViewsManager.showCountryList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            selectedCountryCode: selectedCountryCode,
            updateFunc: updateWithNewCountry)
    }

    @IBAction func emailEditingChanged(_ sender: BSInputLine) {
        BSValidator.emailEditingChanged(sender)
    }
    
    @IBAction func emailEditingDidEnd(_ sender: BSInputLine) {
        _ = validateEmail(ignoreIfEmpty: true)
    }
    
    @IBAction func addressEditingChanged(_ sender: BSInputLine) {
        BSValidator.addressEditingChanged(sender)
    }
    
    @IBAction func addressEditingDidEnd(_ sender: BSInputLine) {
        _ = validateAddress(ignoreIfEmpty: true)
    }
    
    @IBAction func cityEditingChanged(_ sender: BSInputLine) {
        BSValidator.cityEditingChanged(sender)
    }
    
    @IBAction func cityEditingDidEnd(_ sender: BSInputLine) {
        _ = validateCity(ignoreIfEmpty: true)
    }
    
    @IBAction func zipEditingChanged(_ sender: BSInputLine) {
        BSValidator.zipEditingChanged(sender)
    }
    
    @IBAction func zipEditingDidEnd(_ sender: BSInputLine) {
        _ = validateZip(ignoreIfEmpty: true)
    }
    
    @IBAction func stateClick(_ sender: BSInputLine) {
        
        // open the state screen
        BSViewsManager.showStateList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            addressDetails: paymentDetails.getBillingDetails(),
            updateFunc: updateWithNewState)
    }

}
