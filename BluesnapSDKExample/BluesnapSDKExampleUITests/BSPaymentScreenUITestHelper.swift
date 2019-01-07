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

    init(app: XCUIApplication!, keyboardIsHidden : Bool, waitForElementToExistFunc : @escaping (XCUIElement, TimeInterval)->Void, waitForElementToDisappear : @escaping (XCUIElement, TimeInterval)->Void) {
        let elementsQuery = app.scrollViews.otherElements
        ccInput = elementsQuery.element(matching: .any, identifier: "CCN")
        emailInput = elementsQuery.element(matching: .any, identifier: "Email")
        
        self.waitForElementToExistFunc = waitForElementToExistFunc
        self.waitForElementToDisappear = waitForElementToDisappear
        super.init(app: app, keyboardIsHidden: keyboardIsHidden)
        nameInput = elementsQuery.element(matching: .any, identifier: "Name")
        zipInput = elementsQuery.element(matching: .any, identifier: "Zip")
        cityInput = elementsQuery.element(matching: .any, identifier: "City")
        streetInput = elementsQuery.element(matching: .any, identifier: "Street")
        stateInput = elementsQuery.element(matching: .any, identifier: "State")
    }
    
    func getCcInputFieldElement() -> XCUIElement {
        return ccInput.textFields["CcTextField"]
    }
    
    func getExpInputFieldElement() -> XCUIElement {
        return ccInput.textFields["ExpTextField"]
    }
    
    func getCvvInputFieldElement() -> XCUIElement {
        return ccInput.textFields["CvvTextField"]
    }
    
    func getCcInputErrorLabelElement() -> XCUIElement {
        return ccInput.staticTexts["errorLabel"]
    }
    
    func getExpInputErrorLabelElement() -> XCUIElement {
        return ccInput.staticTexts["expErrorLabel"]
    }
    
    func getCvvInputErrorLabelElement() -> XCUIElement {
        return ccInput.staticTexts["cvvErrorLabel"]
    }
    

    // fill CC details 
    func setCcDetails(isOpen: Bool, ccn: String, exp: String, cvv: String) {
        
        // check CCN component state
        checkCcnComponentState(shouldBeOpen: isOpen)
        
        if (!isOpen) {
            let ccnCoverButton = getInputCoverButtonElement(ccInput)
            ccnCoverButton.tap()
        }
        
        let ccnTextField = getCcInputFieldElement()
        ccnTextField.typeText("4111 1111 1111 1111")
        
        checkCcnComponentState(shouldBeOpen: false)
        
        let expTextField = getExpInputFieldElement()
        expTextField.typeText("1126")
        
        let cvvTextField = getCvvInputFieldElement()
        cvvTextField.typeText("333")
    }
    
    // check CCN component state
    func checkCcnComponentState(shouldBeOpen: Bool) {
        
        let ccnTextField = getCcInputFieldElement()
        let expTextField = getExpInputFieldElement()
        let cvvTextField = getCvvInputFieldElement()
        
        if shouldBeOpen {
            XCTAssertTrue(ccnTextField.exists)
            waitForElementToDisappear(expTextField, 3)
            XCTAssertTrue(!expTextField.exists)
            XCTAssertTrue(!cvvTextField.exists)
        } else {
            XCTAssertTrue(!ccnTextField.exists)
            waitForElementToExistFunc(expTextField, 3)
            XCTAssertTrue(expTextField.exists)
            XCTAssertTrue(cvvTextField.exists)
        }
    }
    
    // check visibility of cc line
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
    
    /**
     This test verifies that only the cc number is displayed when choosing a new credit card,
     and that both exp date and cvv number are displayed once entering a valid cc numb.
     It also verifies that the invalid error messages are not displayed.
     */
    func checkNewCCLineVisibility(input: XCUIElement, expectedExists: Bool = true, expectedValue: String, expectedLabelText: String, expectedValid: Bool = true) {
        XCTAssertTrue(ccInput.exists, "CC line is not displayed")
        XCTAssertTrue(getCcInputFieldElement().exists, "CC number field is not displayed")
        checkCcLineInvalidErrorVisibility(input: getCcInputFieldElement(), invalidError: getCcInputErrorLabelElement(), expectedValid: true)
        XCTAssertTrue(!getExpInputFieldElement().exists, "Exp date field is displayed")
        XCTAssertTrue(!getCvvInputFieldElement().exists, "Cvv field is displayed")
        
        //enter a valid cc number to open the line
        getCcInputFieldElement().typeText("4111 1111 1111 1111")
        XCTAssertTrue(getCcInputFieldElement().exists, "CC number field is not displayed")
        XCTAssertTrue(getExpInputFieldElement().exists, "Exp date field is not displayed")
        checkCcLineInvalidErrorVisibility(input: getExpInputFieldElement(), invalidError: getExpInputErrorLabelElement(), expectedValid: true)
        XCTAssertTrue(getCvvInputFieldElement().exists, "Cvv field is not displayed")
        checkCcLineInvalidErrorVisibility(input: getCvvInputFieldElement(), invalidError: getCvvInputErrorLabelElement(), expectedValid: true)
    }
    
    func checkCcLineInvalidErrorVisibility(input: XCUIElement, invalidError: XCUIElement, expectedValid: Bool) {
        XCTAssertTrue(invalidError.exists == !expectedValid, "\(input.identifier) error valid expected to be exists: \(!expectedValid), but was exists: \(invalidError.exists)")
    }
    
    //Pre-condition: country is USA- for state existence and "Billing Zip" label text
    //Pre-condition: all input fields are empty
    func checkEmptyInputs() {
        closeKeyboard()
        app.buttons["PayButton"].tap()
        checkInput(input: nameInput, expectedValue: "John Doe", expectedLabelText: "Name", expectedValid: false)
        checkInput(input: emailInput, expectedValue: "", expectedLabelText: "Email", expectedValid: false)
        checkInput(input: zipInput, expectedValue: "", expectedLabelText: "Billing Zip", expectedValid: false)
        checkInput(input: streetInput, expectedValue: "", expectedLabelText: "Street", expectedValid: false)
        checkInput(input: cityInput, expectedValue: "", expectedLabelText: "City", expectedValid: false)
        checkInput(input: stateInput, expectedValue: "", expectedLabelText: "State", expectedValid: false)
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
