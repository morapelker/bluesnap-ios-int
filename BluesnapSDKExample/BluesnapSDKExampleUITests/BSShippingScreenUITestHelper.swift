//
//  BSShippingScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 12/09/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK

class BSShippingScreenUITestHelper: BSCreditCardScreenUITestHelperBase {
    
    override init(app: XCUIApplication!) {
        super.init(app: app)
        
        let elementsQuery = app.scrollViews.otherElements
        nameInput = elementsQuery.element(matching: .any, identifier: "ShippingName")
        zipInput = elementsQuery.element(matching: .any, identifier: "ShippingZip")
        cityInput = elementsQuery.element(matching: .any, identifier: "ShippingCity")
        streetInput = elementsQuery.element(matching: .any, identifier: "ShippingStreet")
        stateInput = elementsQuery.element(matching: .any, identifier: "ShippingState")
    }
    

    // check visibility of inputs - make sure fields are shown according to configuration
    override func checkInputsVisibility(sdkRequest: BSSdkRequest) {
        super.checkInputsVisibility(sdkRequest: sdkRequest)
        let shippingDetails = sdkRequest.shopperConfiguration.shippingDetails
        checkInput(input: cityInput, expectedExists: true, expectedValue: shippingDetails?.city ?? "", expectedLabelText: "City")
        checkInput(input: streetInput, expectedExists: true, expectedValue: shippingDetails?.address ?? "", expectedLabelText: "Street")
        
        if let countryCode = shippingDetails?.country {
            // check country image - this does not work, don't know how to access the image
            
            // state should be visible for US/Canada/Brazil
            let stateIsVisible = BSCountryManager.getInstance().countryHasStates(countryCode: countryCode)
            var expectedStateValue = ""
            if let stateName = bsCountryManager.getStateName(countryCode : countryCode, stateCode: shippingDetails?.state ?? "") {
                expectedStateValue = stateName
            }
            checkInput(input: stateInput, expectedExists: stateIsVisible, expectedValue: expectedStateValue, expectedLabelText: "State")
        }
        
    }
    
    override func checkPayWithEmptyInputs(sdkRequest: BSSdkRequest) {
        super.checkPayWithEmptyInputs(sdkRequest: sdkRequest)
        checkInput(input: streetInput, expectedValue: "", expectedLabelText: "Street", expectedValid: false)
        checkInput(input: cityInput, expectedValue: "", expectedLabelText: "City", expectedValid: false)
        checkInput(input: stateInput, expectedValue: "", expectedLabelText: "State", expectedValid: false)
    }

    func setFieldValues(shippingDetails: BSShippingAddressDetails, sdkRequest: BSSdkRequest) {
        
        setInputValue(input: nameInput, value: shippingDetails.name ?? "")
        setInputValue(input: zipInput, value: shippingDetails.zip ?? "")
        setInputValue(input: cityInput, value: shippingDetails.city ?? "")
        setInputValue(input: streetInput, value: shippingDetails.address ?? "")
        if let countryCode = shippingDetails.country {
            setCountry(countryCode: countryCode)
            if let stateCode = shippingDetails.state {
                setState(countryCode: countryCode, stateCode: stateCode)
            }
        }
    }


}
