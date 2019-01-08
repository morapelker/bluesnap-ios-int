//
//  BSPaymentScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 07/09/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK
import PassKit

class BSPaymentScreenUITestHelper: BSCreditCardScreenUITestHelperBase {
    
    var ccInput : XCUIElement!
    var emailInput : XCUIElement!
    var waitForElementToExistFunc : (XCUIElement, TimeInterval)->Void;
    var waitForElementToDisappear : (XCUIElement, TimeInterval)->Void;

    init(app: XCUIApplication!, waitForElementToExistFunc : @escaping (XCUIElement, TimeInterval)->Void, waitForElementToDisappear : @escaping (XCUIElement, TimeInterval)->Void) {
        let elementsQuery = app.scrollViews.otherElements
        ccInput = elementsQuery.element(matching: .any, identifier: "CCN")
        emailInput = elementsQuery.element(matching: .any, identifier: "Email")
        
        self.waitForElementToExistFunc = waitForElementToExistFunc
        self.waitForElementToDisappear = waitForElementToDisappear
        super.init(app: app)
        nameInput = elementsQuery.element(matching: .any, identifier: "Name")
        zipInput = elementsQuery.element(matching: .any, identifier: "Zip")
        cityInput = elementsQuery.element(matching: .any, identifier: "City")
        streetInput = elementsQuery.element(matching: .any, identifier: "Street")
        stateInput = elementsQuery.element(matching: .any, identifier: "State")
    }
    
    func getCcInputFieldElement() -> XCUIElement {
        return ccInput.textFields["CcTextField"]
    }
    
    func getLast4digitsLabelElement() -> XCUIElement {
        return ccInput.staticTexts["last4digitsLabel"]
    }
    
    func getExpInputFieldElement() -> XCUIElement {
        return ccInput.textFields["ExpTextField"]
    }
    
    func getCvvInputFieldElement() -> XCUIElement {
        return ccInput.textFields["CvvTextField"]
    }
    
    func getCcInputErrorLabelElement() -> XCUIElement {
        return ccInput.staticTexts["ErrorLabel"]
    }
    
    func getExpInputErrorLabelElement() -> XCUIElement {
        return ccInput.staticTexts["ExpErrorLabel"]
    }
    
    func getCvvInputErrorLabelElement() -> XCUIElement {
        return ccInput.staticTexts["CvvErrorLabel"]
    }
    

    // fill CC details 
    func setCcDetails(isOpen: Bool, ccn: String, exp: String, cvv: String) {
        setCcNumber(isOpen: isOpen, ccn: "4111 1111 1111 1111")
    
        let expTextField = getExpInputFieldElement()
        expTextField.typeText("1126")
        
        let cvvTextField = getCvvInputFieldElement()
        cvvTextField.typeText("333")
    }
    
    func setCcNumber(isOpen: Bool, ccn: String) {
        if (!isOpen) {
            let ccnCoverButton = getInputCoverButtonElement(ccInput)
            ccnCoverButton.tap()
        }
        let ccnTextField = getCcInputFieldElement()
//        let last4digitsLabel = getLast4digitsLabelElement()
//        last4digitsLabel.tap()
        
        ccnTextField.typeText(ccn)
        
    }
    
    /**
     This test verifies the visibility of the cc line,
     and that they show the correct content.
     It also verifies that the invalid error messages are not displayed. "1234 5678 9012 3456"
     */
    func checkNewCCLineVisibility() {
        XCTAssertTrue(ccInput.exists, "CC line is not displayed")
        
        checkCcnComponentState(ccnShouldBeOpen: true, ccn: "1234 5678 9012 3456", last4digits: "", exp: "", cvv: "")
        
        //enter a valid cc number to make exp date and cvv
        setCcNumber(isOpen: true, ccn: "4111 1111 1111 1111")
        
        checkCcnComponentState(ccnShouldBeOpen: false, ccn: "", last4digits: "1111", exp: "MM/YY", cvv: "CVV")
        
//        checkCCLineInput(input: getCcInputFieldElement(), expectedExists: true, expectedValue: "1234 5678 9012 3456", invalidError: getCcInputErrorLabelElement(), expectedValid: true)
//        checkCCLineInput(input: getExpInputFieldElement(), expectedExists: false, expectedValue: "", invalidError: getExpInputErrorLabelElement())
//        checkCCLineInput(input: getCvvInputFieldElement(), expectedExists: false, expectedValue: "", invalidError: getCvvInputErrorLabelElement())
//
//
//        //enter a valid cc number to make exp date and cvv
//        setCcNumber(isOpen: true, ccn: "4111 1111 1111 1111")
//        checkCCLineInput(input: getLast4digitsLabelElement(), expectedExists: true, expectedValue: "1111", invalidError: getCcInputErrorLabelElement(), expectedValid: true)
//        checkCCLineInput(input: getExpInputFieldElement(), expectedExists: true, expectedValue: "", invalidError: getExpInputErrorLabelElement(), expectedValid: true)
//        checkCCLineInput(input: getCvvInputFieldElement(), expectedExists: true, expectedValue: "", invalidError: getCvvInputErrorLabelElement(), expectedValid: true)
//
        //        XCTAssertTrue(ccInput.exists, "CC line is not displayed")
        //        XCTAssertTrue(getCcInputFieldElement().exists, "CC number field is not displayed")
        //        checkCcLineInvalidErrorVisibility(input: getCcInputFieldElement(), invalidError: getCcInputErrorLabelElement(), expectedValid: true)
        //        XCTAssertTrue(!getExpInputFieldElement().exists, "Exp date field is displayed")
        //        XCTAssertTrue(!getCvvInputFieldElement().exists, "Cvv field is displayed")
        //
        //        //enter a valid cc number to make exp date and cvv
        //        setCcNumber(isOpen: true, ccn: "4111 1111 1111 1111")
        //        XCTAssertTrue(getLast4digitsLabelElement().exists, "Last 4 digits field is not displayed")
        //        XCTAssertTrue(getExpInputFieldElement().exists, "Exp date field is not displayed")
        //        checkCcLineInvalidErrorVisibility(input: getExpInputFieldElement(), invalidError: getExpInputErrorLabelElement(), expectedValid: true)
        //        XCTAssertTrue(getCvvInputFieldElement().exists, "Cvv field is not displayed")
        //        checkCcLineInvalidErrorVisibility(input: getCvvInputFieldElement(), invalidError: getCvvInputErrorLabelElement(), expectedValid: true)
    }
    
    // check CCN component state
    func checkCcnComponentState(ccnShouldBeOpen: Bool, ccn: String, last4digits: String, exp: String, cvv: String) {
        
        if ccnShouldBeOpen {
            checkCCLineInput(input: getCcInputFieldElement(), expectedExists: true, expectedValue: ccn, invalidError: getCcInputErrorLabelElement())
            waitForElementToDisappear(getExpInputFieldElement(), 3)
            checkCCLineInput(input: getExpInputFieldElement(), expectedExists: false, expectedValue: "", invalidError: getExpInputErrorLabelElement())
            checkCCLineInput(input: getCvvInputFieldElement(), expectedExists: false, expectedValue: "", invalidError: getCvvInputErrorLabelElement())
        } else {
            //TODO: fix this
//            checkCCLineInput(input: getLast4digitsLabelElement(), expectedExists: true, expectedValue: last4digits, invalidError: getCcInputErrorLabelElement())
            waitForElementToExistFunc(getExpInputFieldElement(), 3)
            checkCCLineInput(input: getExpInputFieldElement(), expectedExists: true, expectedValue: exp, invalidError: getExpInputErrorLabelElement())
            checkCCLineInput(input: getCvvInputFieldElement(), expectedExists: true, expectedValue: cvv, invalidError: getCvvInputErrorLabelElement())
        }
        
        //        let ccnTextField = getCcInputFieldElement()
        //        let expTextField = getExpInputFieldElement()
        //        let cvvTextField = getCvvInputFieldElement()
        //
        //        if shouldBeOpen {
        //            XCTAssertTrue(ccnTextField.exists)
        //            waitForElementToDisappear(expTextField, 3)
        //            XCTAssertTrue(!expTextField.exists)
        //            XCTAssertTrue(!cvvTextField.exists)
        //        } else {
        //            XCTAssertTrue(!ccnTextField.exists)
        //            waitForElementToExistFunc(expTextField, 3)
        //            XCTAssertTrue(expTextField.exists)
        //            XCTAssertTrue(cvvTextField.exists)
        //        }
    }
    
    //check a cc line input existance, value and validity
    func checkCCLineInput(input: XCUIElement, expectedExists: Bool = true, expectedValue: String, invalidError: XCUIElement, expectedValid: Bool = true) {
        
        XCTAssertTrue(input.exists == expectedExists, "\(input.identifier) expected to be exists: \(expectedExists), but was exists: \(input.exists)")
        
        if input.exists {
            let value = input.value as! String
            XCTAssertTrue(expectedValue == value, "\(input.identifier) expected value: \(expectedValue), actual value: \(value)")
            
            XCTAssertTrue(invalidError.exists == !expectedValid, "\(input.identifier) error valid expected to be exists: \(!expectedValid), but was exists: \(invalidError.exists)")
            
        }
    }
    
    func checkCcLineInvalidErrorVisibility(input: XCUIElement, invalidError: XCUIElement, expectedValid: Bool) {
        XCTAssertTrue(invalidError.exists == !expectedValid, "\(input.identifier) error valid expected to be exists: \(!expectedValid), but was exists: \(invalidError.exists)")
    }
    
    // check visibility of cc line
    /**
     This test verifies the visibility of the cc line,
     and that they show the correct content.
     It also verifies that the invalid error messages are not displayed.
     */
    func checkCCLineInputs(sdkRequest: BSSdkRequest) {
        
    }

    // check visibility of inputs - make sure fields are shown according to configuration
    override func checkInputsVisibility(sdkRequest: BSSdkRequest) {
        super.checkInputsVisibility(sdkRequest: sdkRequest)
        let billingDetails = sdkRequest.shopperConfiguration.billingDetails
        checkInput(input: emailInput, expectedExists: sdkRequest.shopperConfiguration.withEmail, expectedValue: billingDetails?.email ?? "", expectedLabelText: "Email")
        checkInput(input: cityInput, expectedExists: sdkRequest.shopperConfiguration.fullBilling, expectedValue: billingDetails?.city ?? "", expectedLabelText: "City")
        checkInput(input: streetInput, expectedExists: sdkRequest.shopperConfiguration.fullBilling, expectedValue: billingDetails?.address ?? "", expectedLabelText: "Street")
        
        if let countryCode = billingDetails?.country {
            // check country image - this does not work, don;t know how to access the image
            //let countryFlagButton = getInputImageButtonElement(nameInput)
            //assert(countryFlagButton.exists)
            //let countryImage = countryFlagButton.otherElements.images[countryCode]
            //assert(countryImage.exists)
            
            // state should be visible for US/Canada/Brazil
            let stateIsVisible = sdkRequest.shopperConfiguration.fullBilling && BSCountryManager.getInstance().countryHasStates(countryCode: countryCode)
            var expectedStateValue = ""
            if let stateName = bsCountryManager.getStateName(countryCode : countryCode, stateCode: billingDetails?.state ?? "") {
                expectedStateValue = stateName
            }
            checkInput(input: stateInput, expectedExists: stateIsVisible, expectedValue: expectedStateValue, expectedLabelText: "State")
        }

        
    }
    
    
    
    //Pre-condition: country is USA- for state existence and "Billing Zip" label text
    //Pre-condition: full billing checkout
    //Pre-condition: all cc line and input fields are empty
    override func checkPayWithEmptyInputs(sdkRequest: BSSdkRequest) {
        super.checkPayWithEmptyInputs(sdkRequest: sdkRequest)
        checkInput(input: emailInput, expectedValue: "", expectedLabelText: "Email", expectedValid: false)
        checkInput(input: streetInput, expectedValue: "", expectedLabelText: "Street", expectedValid: false)
        checkInput(input: cityInput, expectedValue: "", expectedLabelText: "City", expectedValid: false)
        checkInput(input: stateInput, expectedValue: "", expectedLabelText: "State", expectedValid: false)
        
        // TODO: add this once the issue is fixed
//        checkCcLineInvalidErrorVisibility(input: getCcInputFieldElement(), invalidError: getCcInputErrorLabelElement(), expectedValid: false)
        
        checkCcLineInvalidErrorVisibility(input: getExpInputFieldElement(), invalidError: getExpInputErrorLabelElement(), expectedValid: false)
        
        // TODO: add this once the issue is fixed
//        checkCcLineInvalidErrorVisibility(input: getCvvInputFieldElement(), invalidError: getCvvInputErrorLabelElement(), expectedValid: false)
    }
    
    func checkInvalidBillingInfoInputs() {
        checkInvalidFieldInputs(input: nameInput, invalidValuesToCheck: ["Sawyer", "L Fleur", "La F"], validValue: "Fanny Brice", expectedLabelText: "Name", inputToTap: emailInput)
        
        checkInvalidFieldInputs(input: emailInput, invalidValuesToCheck: ["broadwaydancecenter.com", "broadwaydancecenter@gmail"], validValue: "broadwaydancecenter@gmail.com", expectedLabelText: "Email", inputToTap: zipInput)
        
        //Pre-condition: country is USA
        checkInvalidFieldInputs(input: zipInput, invalidValuesToCheck: ["12"], validValue: "12345 abcde", expectedLabelText: "Billing Zip", inputToTap: streetInput)
        
        checkInvalidFieldInputs(input: streetInput, invalidValuesToCheck: ["ab"], validValue: "Broadway 777", expectedLabelText: "Street", inputToTap: cityInput)
        
        checkInvalidFieldInputs(input: cityInput, invalidValuesToCheck: ["ab"], validValue: "New York", expectedLabelText: "City", inputToTap: nameInput)
    }
    
    func checkInvalidFieldInputs(input: XCUIElement, invalidValuesToCheck: [String], validValue: String, expectedLabelText: String, inputToTap: XCUIElement) {
        for invalidValue in invalidValuesToCheck{
            validateInput(input: input, value: validValue, expectedLabelText: expectedLabelText, expectedValid: true, inputToTap: inputToTap)
            validateInput(input: input, value: invalidValue, expectedLabelText: expectedLabelText, expectedValid: false, inputToTap: inputToTap)
        }
        validateInput(input: input, value: validValue, expectedLabelText: expectedLabelText, expectedValid: true, inputToTap: inputToTap)
    }
    
    func setFieldValues(billingDetails: BSBillingAddressDetails, sdkRequest: BSSdkRequest, ignoreCountry: Bool? = false) {
    
        setInputValue(input: nameInput, value: billingDetails.name ?? "")
        if sdkRequest.shopperConfiguration.withEmail {
            setInputValue(input: emailInput, value: billingDetails.email ?? "")
        }
        setInputValue(input: zipInput, value: billingDetails.zip ?? "")
        if sdkRequest.shopperConfiguration.fullBilling {
            setInputValue(input: cityInput, value: billingDetails.city ?? "")
            setInputValue(input: streetInput, value: billingDetails.address ?? "")
        }
        if ignoreCountry == false {
            if let countryCode = billingDetails.country {
                setCountry(countryCode: countryCode)
                if sdkRequest.shopperConfiguration.fullBilling {
                    if let stateCode = billingDetails.state {
                        setState(countryCode: countryCode, stateCode: stateCode)
                    }
                }
            }
        }
    }
    
    func setShippingSameAsBillingSwitch(shouldBeOn: Bool) {
        
        // set with Shipping switch = on
        let shippingAsBillingSwitch = app.switches["ShippingAsBillingSwitch"]
        let switchValue = (shippingAsBillingSwitch.value as? String) ?? "0"
        if (switchValue == "0" && shouldBeOn) || (switchValue == "1" && !shouldBeOn) {
            shippingAsBillingSwitch.tap()
        }
    }

    
    func validateInput(input: XCUIElement, value: String, expectedLabelText: String, expectedValid: Bool, inputToTap: XCUIElement) {
        setInputValue(input: input, value: value)
        getInputFieldElement(inputToTap).tap()
        checkInput(input: input, expectedValue: value, expectedLabelText: expectedLabelText, expectedValid: expectedValid)
        
    }
    
}
