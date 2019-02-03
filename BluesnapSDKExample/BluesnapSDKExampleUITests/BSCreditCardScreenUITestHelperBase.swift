//
//  BSCreditCardScreenUITestHelperBase.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 07/01/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK
import PassKit

class BSCreditCardScreenUITestHelperBase {
    
    var app: XCUIApplication!
    var nameInput : XCUIElement!
    var zipInput : XCUIElement!
    var cityInput : XCUIElement!
    var streetInput : XCUIElement!
    var stateInput : XCUIElement!
    
    let bsCountryManager = BSCountryManager.getInstance()
    
    init(app: XCUIApplication!) {
        self.app = app
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
    
    func getInputImageButtonElement() -> XCUIElement {
        return nameInput.buttons["ImageButton"]
    }
    
    func closeKeyboard() {
//        if (!keyboardIsHidden) {
        nameInput.tap()
        if (app.keyboards.count > 0) {
            let doneBtn = app.keyboards.buttons["Done"]
            if doneBtn.exists && doneBtn.isHittable {
                doneBtn.tap()
            }
        }
    }
    
    /**
     This test verifies the visibility of inputs - make sure fields are shown according to configuration,
     and that they show the correct content.
     It also verifies that the invalid error messages are not displayed.
     */
    func checkInputsVisibility(sdkRequest: BSSdkRequest, shopperDetails: BSBaseAddressDetails?, zipLabel: String) {
        checkInput(input: nameInput, expectedValue: shopperDetails?.name.isEmpty ?? true ? "John Doe" : shopperDetails!.name , expectedLabelText: "Name")
        
        // zip should be hidden only for country that does not have zip; label also changes according to country
        let country = shopperDetails?.country ?? "US"
        let expectedZipLabelText = (country == "US") ? zipLabel : "Postal Code"
        let zipShouldBeVisible = checkCountryHasZip(country: country)
        checkInput(input: zipInput, expectedExists: zipShouldBeVisible, expectedValue: shopperDetails?.zip ?? "", expectedLabelText: expectedZipLabelText)
    }

    //check the input existance, tag, value and validity
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
    
    /**
     This test verifies the visibility of zip input field,
     according to default country and specific countries.
     */
    func checkZipVisibility(defaultCountry: String, zipLabel: String) {
        setCountry(countryCode: defaultCountry)
        // check whether the zip field is visible to the user or not, according to defaultCountry
        let expectedZipLabelText = (defaultCountry == "US") ? zipLabel : "Postal Code"
        let zipShouldBeVisible = checkCountryHasZip(country: defaultCountry)
        checkInput(input: zipInput, expectedExists: zipShouldBeVisible, expectedValue: "", expectedLabelText: expectedZipLabelText)
        
        // verify that the zip field is visible when changing to USA (has zip)
        setCountry(countryCode: "US")
        checkInput(input: zipInput, expectedExists: true, expectedValue: "", expectedLabelText: zipLabel)
        
        // verify that the zip field is visible when changing to Angola (doesn't have zip)
        setCountry(countryCode: "AO")
        checkInput(input: zipInput, expectedExists: false, expectedValue: "", expectedLabelText: expectedZipLabelText)
        
        // verify that the zip field is visible when changing to Israel (has postal code)
        setCountry(countryCode: "IL")
        checkInput(input: zipInput, expectedExists: true, expectedValue: "", expectedLabelText: "Postal Code")
        
//        setCountry(countryCode: defaultCountry)

    }
    
    /**
     This test verifies the visibility of state input field,
     according to default country and specific countries.
     (this test ends with default country selected)
     */
    func checkStateVisibility(defaultCountry: String) {
        // check whether the state field is visible to the user or not, according to defaultCountry
        setCountry(countryCode: defaultCountry)
        let stateIsVisible = BSCountryManager.getInstance().countryHasStates(countryCode: defaultCountry)
        checkInput(input: stateInput, expectedExists: stateIsVisible, expectedValue: "", expectedLabelText: "State")
        
        // verify that the state field is visible when changing to USA (has state)
        setCountry(countryCode: "US")
        checkInput(input: stateInput, expectedExists: true, expectedValue: "", expectedLabelText: "State")
        
        // verify that the zip field is visible when changing to Israel (doesn't have state)
        setCountry(countryCode: "IL")
        checkInput(input: stateInput, expectedExists: false, expectedValue: "", expectedLabelText: "State")
        
        // verify that the state field is visible when changing to Canada (has state)
        setCountry(countryCode: "CA")
        checkInput(input: stateInput, expectedExists: true, expectedValue: "", expectedLabelText: "State")
        
        // verify that the zip field is visible when changing to Spain (doesn't have state)
        setCountry(countryCode: "ES")
        checkInput(input: stateInput, expectedExists: false, expectedValue: "", expectedLabelText: "State")
        
        // verify that the state field is visible when changing to Brazil (has state)
        setCountry(countryCode: "BR")
        checkInput(input: stateInput, expectedExists: true, expectedValue: "", expectedLabelText: "State")
        
        setCountry(countryCode: defaultCountry)
    }

    //Pre-condition: full billing or shipping checkout and country is USA- for state existence and "Billing Zip"/"Shipping Zip" label text
    //Pre-condition: all cc line and input fields are empty
    func checkPayWithEmptyInputs(sdkRequest: BSSdkRequest, shopperDetails: BSBaseAddressDetails?, payButtonId: String, zipLabel: String) {
        pressPayButton(payButtonId: payButtonId)

        checkInput(input: nameInput, expectedValue: "John Doe", expectedLabelText: "Name", expectedValid: false)
        
        let country = shopperDetails?.country ?? "US"
        
        let expectedZipLabelText = (country == "US") ? zipLabel : "Postal Code"
        checkInput(input: zipInput, expectedValue: "", expectedLabelText: expectedZipLabelText, expectedValid: false)
    }
    
    /**
     This test verifies the invalid error messages appearance for the billing/shipping
     info in the payment/shipping screen
     Pre-condition: country has zip and state
     Pre-condition: full billing is enabled/it is shipping screen
     */
    func checkInvalidInfoInputs(payButtonId: String) {
        checkInvalidFieldInputs(input: nameInput, invalidValuesToCheck: ["Sawyer", "L Fleur", "La F"], validValue: "Fanny Brice", expectedLabelText: "Name", inputToTap: zipInput)
        
        checkInvalidFieldInputs(input: streetInput, invalidValuesToCheck: ["ab"], validValue: "Broadway 777", expectedLabelText: "Street", inputToTap: cityInput)
        
        checkInvalidFieldInputs(input: cityInput, invalidValuesToCheck: ["ab"], validValue: "New York", expectedLabelText: "City", inputToTap: nameInput)
        checkInvalidState(payButtonId: payButtonId)
    }
    
    //Pre-condition: country has state
    func checkInvalidState(payButtonId: String) {
        pressPayButton(payButtonId: payButtonId)
        checkInput(input: stateInput, expectedValue: "", expectedLabelText: "State", expectedValid: false)
        setState(countryCode: "US", stateCode: "NY")
        checkInput(input: stateInput, expectedValue: "New York", expectedLabelText: "State", expectedValid: true)
    }
    
    func checkInvalidFieldInputs(input: XCUIElement, invalidValuesToCheck: [String], validValue: String, expectedLabelText: String, inputToTap: XCUIElement) {
        for invalidValue in invalidValuesToCheck{
            setAndValidateInput(input: input, value: validValue, expectedLabelText: expectedLabelText, expectedValid: true, inputToTap: inputToTap)
            setAndValidateInput(input: input, value: invalidValue, expectedLabelText: expectedLabelText, expectedValid: false, inputToTap: inputToTap)
        }
        setAndValidateInput(input: input, value: validValue, expectedLabelText: expectedLabelText, expectedValid: true, inputToTap: inputToTap)
    }
    
    func setAndValidateInput(input: XCUIElement, value: String, expectedLabelText: String, expectedValid: Bool, inputToTap: XCUIElement) {
        setInputValue(input: input, value: value)
        getInputFieldElement(inputToTap).tap()
        checkInput(input: input, expectedValue: value, expectedLabelText: expectedLabelText, expectedValid: expectedValid)
    }
    
    /**
     This test verifies that changing the country in one screen (billing/shipping)
     doesn't change the country in the other.
     */
    func checkCountryChangesPerScreen(defaultCountry: String) {
        //todo: write this test once we're able to check cuntry image 
        
    }
    
    
    func setCountry(countryCode: String) {
        
        if let countryName = bsCountryManager.getCountryName(countryCode: countryCode) {
            let countryImageButton = getInputImageButtonElement()
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
    
    func checkCountryHasZip(country: String) -> Bool {
        let countryHasZip = !BSCountryManager.getInstance().countryHasNoZip(countryCode: country)
        return countryHasZip
    }
    
    func checkCountryHasState(country: String) -> Bool {
        var countryHasState = false
        
        if country == "US" || country == "CA" || country == "BR" {
            countryHasState =  true
        }
        
        return countryHasState
    }
    
    func pressPayButton(payButtonId: String) {
        closeKeyboard()
        app.buttons[payButtonId].tap()
    }
    
    func pressBackButton() {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
}

extension XCUIElement {
    func clearText() {
        tap()
        guard let stringValue = self.value as? String else {
            return
        }
        
        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        self.typeText(deleteString)
    }
}
