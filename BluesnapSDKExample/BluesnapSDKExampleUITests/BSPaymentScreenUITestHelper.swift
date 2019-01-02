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

class BSPaymentScreenUITestHelper {
    
    var app: XCUIApplication!
    var ccInput : XCUIElement!
    var nameInput : XCUIElement!
    var emailInput : XCUIElement!
    var zipInput : XCUIElement!
    var cityInput : XCUIElement!
    var streetInput : XCUIElement!
    var stateInput : XCUIElement!
    var keyBoardIsVisible = false
    var keyboardIsHidden = true
    var waitForElementToExistFunc : (XCUIElement, TimeInterval)->Void;
    var waitForElementToDisappear : (XCUIElement, TimeInterval)->Void;

    let bsCountryManager = BSCountryManager.getInstance()

    init(app: XCUIApplication!, keyboardIsHidden : Bool, waitForElementToExistFunc : @escaping (XCUIElement, TimeInterval)->Void, waitForElementToDisappear : @escaping (XCUIElement, TimeInterval)->Void) {
        self.app = app
        let elementsQuery = app.scrollViews.otherElements
        ccInput = elementsQuery.element(matching: .any, identifier: "CCN")
        nameInput = elementsQuery.element(matching: .any, identifier: "Name")
        emailInput = elementsQuery.element(matching: .any, identifier: "Email")
        zipInput = elementsQuery.element(matching: .any, identifier: "Zip")
        cityInput = elementsQuery.element(matching: .any, identifier: "City")
        streetInput = elementsQuery.element(matching: .any, identifier: "Street")
        stateInput = elementsQuery.element(matching: .any, identifier: "State")
        self.keyboardIsHidden = keyboardIsHidden
        self.waitForElementToExistFunc = waitForElementToExistFunc
        self.waitForElementToDisappear = waitForElementToDisappear
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
    
    func getInputFieldElement(_ input : XCUIElement) -> XCUIElement {
        return input.textFields["TextField"]
    }
    
    func getInputErrorLabelElement(_ input : XCUIElement) -> XCUIElement {
        return input.staticTexts["ErrorLabel"]
    }
    
    func getInputLabelElement(_ input : XCUIElement) -> XCUIElement {
        return input.staticTexts["InputLabel"]
    }
    
    func getInputCoverButtonElement(_ input : XCUIElement) -> XCUIElement {
        return input.buttons["FieldCoverButton"]
    }
    
    func getInputImageButtonElement(_ input : XCUIElement) -> XCUIElement {
        return input.buttons["ImageButton"]
    }

    func closeKeyboard() {
        if (!keyboardIsHidden) {
            nameInput.tap()
            if (app.keyboards.count > 0) {
                let doneBtn = app.keyboards.buttons["Done"]
                if doneBtn.exists && doneBtn.isHittable {
                    doneBtn.tap()
                }
            }
        }
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

    // check visibility of inputs - make sure fields are shown according to configuration
    func checkInputs(sdkRequest: BSSdkRequest) {
        
        if let billingDetails = sdkRequest.shopperConfiguration.billingDetails {
            checkInput(input: nameInput, expectedValue: billingDetails.name ?? "", expectedLabelText: "Name")
            checkInput(input: emailInput, expectedExists: sdkRequest.shopperConfiguration.withEmail, expectedValue: billingDetails.email ?? "", expectedLabelText: "Email")
            checkInput(input: cityInput, expectedExists: sdkRequest.shopperConfiguration.fullBilling, expectedValue: billingDetails.city ?? "", expectedLabelText: "City")
            checkInput(input: streetInput, expectedExists: sdkRequest.shopperConfiguration.fullBilling, expectedValue: billingDetails.address ?? "", expectedLabelText: "Street")

            // zip should be hidden only for country that does not have zip; label also changes according to country
            let expectedZipLabelText = (billingDetails.country == "US") ? "Billing Zip" : "Postal Code"
            let zipShouldBeVisible = !BSCountryManager.getInstance().countryHasNoZip(countryCode: billingDetails.country ?? "")
            checkInput(input: zipInput, expectedExists: zipShouldBeVisible, expectedValue: billingDetails.zip ?? "", expectedLabelText: expectedZipLabelText)
            if let countryCode = billingDetails.country {
                // check country image - this does not work, don;t know how to access the image
                //let countryFlagButton = getInputImageButtonElement(nameInput)
                //assert(countryFlagButton.exists)
                //let countryImage = countryFlagButton.otherElements.images[countryCode]
                //assert(countryImage.exists)
                
                // state should be visible for US/Canada/Brazil
                let stateIsVisible = sdkRequest.shopperConfiguration.fullBilling && BSCountryManager.getInstance().countryHasStates(countryCode: countryCode)
                var expectedStateValue = ""
                if let stateName = bsCountryManager.getStateName(countryCode : countryCode, stateCode: billingDetails.state ?? "") {
                    expectedStateValue = stateName
                }
                checkInput(input: stateInput, expectedExists: stateIsVisible, expectedValue: expectedStateValue, expectedLabelText: "State")
            }

        }
    }
    
    func checkInvalidNameInputs() {
        validateInput(input: nameInput, value: "Fanny Brice", expectedLabelText: "Name", expectedValid: true, inputToTap: emailInput)
        validateInput(input: nameInput, value: "Sawyer", expectedLabelText: "Name", expectedValid: false, inputToTap: emailInput)
        validateInput(input: nameInput, value: "Fanny Brice", expectedLabelText: "Name", expectedValid: true, inputToTap: emailInput)
        validateInput(input: nameInput, value: "L Fleur", expectedLabelText: "Name", expectedValid: false, inputToTap: emailInput)
        validateInput(input: nameInput, value: "Fanny Brice", expectedLabelText: "Name", expectedValid: true, inputToTap: emailInput)
        validateInput(input: nameInput, value: "La F", expectedLabelText: "Name", expectedValid: false, inputToTap: emailInput)
        validateInput(input: nameInput, value: "Fanny Brice", expectedLabelText: "Name", expectedValid: true, inputToTap: emailInput)
    }
    
    func checkInvalidEmailInputs() {
        validateInput(input: emailInput, value: "broadwaydancecenter@gmail.com", expectedLabelText: "Email", expectedValid: true, inputToTap: zipInput)
        validateInput(input: emailInput, value: "broadwaydancecenter.com", expectedLabelText: "Email", expectedValid: false, inputToTap: zipInput)
        validateInput(input: emailInput, value: "broadwaydancecenter@gmail.com", expectedLabelText: "Email", expectedValid: true, inputToTap: zipInput)
        validateInput(input: emailInput, value: "broadwaydancecenter@gmail", expectedLabelText: "Email", expectedValid: false, inputToTap: zipInput)
        validateInput(input: emailInput, value: "broadwaydancecenter@gmail.com", expectedLabelText: "Email", expectedValid: true, inputToTap: zipInput)
        validateInput(input: emailInput, value: "broadwaydancecenter*@gmail.com", expectedLabelText: "Email", expectedValid: false, inputToTap: zipInput)
        validateInput(input: emailInput, value: "broadwaydancecenter@gmail.com", expectedLabelText: "Email", expectedValid: true, inputToTap: zipInput)
    }
    
    //Pre-condition: country is USA
    func checkInvalidZipInputs() {
        validateInput(input: zipInput, value: "12345", expectedLabelText: "Billing Zip", expectedValid: true, inputToTap: streetInput)
        validateInput(input: zipInput, value: "12345*", expectedLabelText: "Postal Code", expectedValid: false, inputToTap: streetInput)
        validateInput(input: zipInput, value: "12345 abcde", expectedLabelText: "Billing Zip", expectedValid: true, inputToTap: streetInput)
    }
    
    func checkInvalidStreetInputs() {
        validateInput(input: streetInput, value: "Broadway 777", expectedLabelText: "Street", expectedValid: true, inputToTap: cityInput)
        validateInput(input: streetInput, value: "a", expectedLabelText: "Street", expectedValid: false, inputToTap: cityInput)
        validateInput(input: streetInput, value: "Broadway 777", expectedLabelText: "Street", expectedValid: true, inputToTap: cityInput)
        validateInput(input: streetInput, value: "         ", expectedLabelText: "Street", expectedValid: false, inputToTap: cityInput)
        validateInput(input: streetInput, value: "Broadway 777", expectedLabelText: "Street", expectedValid: true, inputToTap: cityInput)
    }
    
    func checkInvalidCityInputs() {
        validateInput(input: cityInput, value: "New York", expectedLabelText: "City", expectedValid: true, inputToTap: nameInput)
        validateInput(input: cityInput, value: "a", expectedLabelText: "Email", expectedValid: false, inputToTap: nameInput)
        validateInput(input: cityInput, value: "New York", expectedLabelText: "City", expectedValid: true, inputToTap: nameInput)
        validateInput(input: cityInput, value: "       ", expectedLabelText: "Email", expectedValid: false, inputToTap: nameInput)
        validateInput(input: cityInput, value: "New York", expectedLabelText: "City", expectedValid: true, inputToTap: nameInput)
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

    
    func setCountry(countryCode: String) {
        
        if let countryName = bsCountryManager.getCountryName(countryCode: countryCode) {
            let countryImageButton = getInputImageButtonElement(nameInput)
            countryImageButton.tap()
            app.searchFields["Search"].tap()
            app.searchFields["Search"].typeText(countryName)
            app.tables.staticTexts[countryName].tap()
        }
    }
    
    func setState(countryCode: String, stateCode: String) {
        
        if let stateName = bsCountryManager.getStateName(countryCode : countryCode, stateCode: stateCode) {
            let stateButton = getInputCoverButtonElement(stateInput)
            stateButton.tap()
            app.searchFields["Search"].tap()
            app.searchFields["Search"].typeText(stateName)
            app.tables.staticTexts[stateName].tap()
        }
    }
    
    func setInputValue(input: XCUIElement, value: String) {
        
        let textField = getInputFieldElement(input)
        if textField.exists {
            let oldValue = textField.value as? String ?? ""
            if oldValue != value {
                textField.tap()
                if oldValue.count > 0 {
                    let deleteString = oldValue.map { _ in "\u{8}" }.joined(separator: "")
                    textField.typeText(deleteString)
                }
                textField.typeText(value)
            }
        }
    }
    
    func checkInput(input: XCUIElement, expectedExists: Bool = true, expectedValue: String, expectedLabelText: String, expectedValid: Bool = true) {
        
        XCTAssertTrue(input.exists == expectedExists, "\(input.identifier) expected to be exists: \(expectedExists), but was exists: \(input.exists)")
        
        if input.exists {
            let textField = getInputFieldElement(input)
            let value = textField.value as! String
            XCTAssertTrue(expectedValue == value, "\(input.identifier) expected value: \(expectedValue), actual value: \(value)")
            
            let titleLabel = getInputLabelElement(input)
            let titleLabelText: String = titleLabel.label //label.value as! String
            XCTAssertTrue(titleLabelText == expectedLabelText, "\(input.identifier) expected value: \(expectedLabelText), actual value: \(titleLabelText)")
            
            
            let errorLabel = getInputErrorLabelElement(input)
            XCTAssertTrue(errorLabel.exists == !expectedValid, "error message for \(input.identifier) expected to be exists: \(expectedValid), but was exists: \(errorLabel.exists)")
            
        }
    }
    
    func validateInput(input: XCUIElement, value: String, expectedLabelText: String, expectedValid: Bool, inputToTap: XCUIElement) {
        setInputValue(input: input, value: value)
        getInputFieldElement(inputToTap).tap()
        checkInput(input: input, expectedValue: value, expectedLabelText: expectedLabelText, expectedValid: expectedValid)
        
    }
    
}
