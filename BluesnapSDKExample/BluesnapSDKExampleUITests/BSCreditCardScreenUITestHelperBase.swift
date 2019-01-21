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
//    var keyboardIsHidden = true
    
    let bsCountryManager = BSCountryManager.getInstance()
    
    init(app: XCUIApplication!) {
        self.app = app
//        self.keyboardIsHidden = keyboardIsHidden
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
    func checkInputsVisibility(sdkRequest: BSSdkRequest) {
        let shopperDetails: BSBaseAddressDetails?
        shopperDetails = self is BSPaymentScreenUITestHelper ? sdkRequest.shopperConfiguration.billingDetails : sdkRequest.shopperConfiguration.shippingDetails
        
        checkInput(input: nameInput, expectedValue: shopperDetails?.name.isEmpty ?? true ? "John Doe" : shopperDetails!.name , expectedLabelText: "Name")
        
        // zip should be hidden only for country that does not have zip; label also changes according to country
        let country = shopperDetails?.country ?? "US"
        //TODO: fix this to support Shipping zip as well- check if it works
        let expectedZipLabelText = (country == "US") ? (self is BSPaymentScreenUITestHelper ? "Billing Zip" : "Shipping Zip") : "Postal Code"
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

    //Pre-condition: full billing or shipping checkout and country is USA- for state existence and "Billing Zip" label text
    //Pre-condition: all cc line and input fields are empty
    func checkPayWithEmptyInputs(sdkRequest: BSSdkRequest) {
        let shopperDetails: BSBaseAddressDetails?
        shopperDetails = self is BSPaymentScreenUITestHelper ? sdkRequest.shopperConfiguration.billingDetails : sdkRequest.shopperConfiguration.shippingDetails
        
        closeKeyboard()
        app.buttons["PayButton"].tap()
        checkInput(input: nameInput, expectedValue: "John Doe", expectedLabelText: "Name", expectedValid: false)
        
        let country = shopperDetails?.country ?? "US"
        
        if checkCountryHasZip(country: country){
            checkInput(input: zipInput, expectedValue: "", expectedLabelText: "Billing Zip", expectedValid: false)
        }
        
    }
    
    /**
     This test verifies the invalid error messages appearance for the billing/shipping
     info in the payment/shipping screen
     Pre-condition: country is USA (for zip existence)
     Pre-condition: full billing is enabled/it is shipping screen
     */
    func checkInvalidInfoInputs() {
        checkInvalidFieldInputs(input: nameInput, invalidValuesToCheck: ["Sawyer", "L Fleur", "La F"], validValue: "Fanny Brice", expectedLabelText: "Name", inputToTap: zipInput)
        
        checkInvalidFieldInputs(input: streetInput, invalidValuesToCheck: ["ab"], validValue: "Broadway 777", expectedLabelText: "Street", inputToTap: cityInput)
        
        checkInvalidFieldInputs(input: cityInput, invalidValuesToCheck: ["ab"], validValue: "New York", expectedLabelText: "City", inputToTap: nameInput)
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
