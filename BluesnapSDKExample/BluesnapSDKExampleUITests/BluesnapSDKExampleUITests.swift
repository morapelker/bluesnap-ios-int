//
//  BluesnapSDKExampleUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Oz on 26/03/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
import Foundation
import PassKit
import BluesnapSDK
@testable import BluesnapSDKIntegrationTests //TODO: make it work

class BluesnapSDKExampleUITests: XCTestCase {
    
//    let keyboardIsHidden = false
    private var app: XCUIApplication! //using Implicitly Unwrapped Optionals for initialization purpose
    private var defaultCountry: String!
    private var checkoutCurrency: String!
    private var purchaseAmount: Double!
    private var taxPercent: Double!
    private var sdkRequest: BSSdkRequest!
    private var shippingSameAsBilling: Bool = false
    private var isReturningShopper: Bool = false
    
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()
        defaultCountry = NSLocale.current.regionCode ?? BSCountryManager.US_COUNTRY_CODE
        checkoutCurrency = "USD"
        purchaseAmount = 30
        taxPercent = 0.05


        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func setUpForSdk(fullBilling: Bool, withShipping: Bool, withEmail: Bool, allowCurrencyChange: Bool = true, isReturningShopper: Bool = false, tapExistingCc: Bool = false){
        
        // set returning shopper and shipping same as biiling properties
        self.isReturningShopper = isReturningShopper
        if (fullBilling && withShipping && !isReturningShopper) {
            shippingSameAsBilling = true
        }
        
        // prepare sdk request
        prepareSdkRequest(fullBilling: fullBilling, withShipping: withShipping, withEmail: withEmail, allowCurrencyChange: allowCurrencyChange)
        
        // start checkout
        gotoPaymentScreen(tapExistingCc: tapExistingCc)
    }
    
    /* -------------------------------- Returning shopper tests ---------------------------------------- */
    
    func testShortReturningShopperExistingCcFlow() {
        
        // no full billing, no shipping, no email, new CC
        
        setUpForSdk(fullBilling: false, withShipping: false, withEmail: false, isReturningShopper: true, tapExistingCc: true)
        
        let _ = waitForExistingCcScreen()
        
        let payButton = checkPayButton()
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }
    
    func testShortReturningShopperExistingCcFlowWithShipping() {
        
        // no full billing, with shipping, no email, new CC
        
        setUpForSdk(fullBilling: false, withShipping: true, withEmail: false, isReturningShopper: true, tapExistingCc: true)
        
        let existingCcHelper = waitForExistingCcScreen()

        // edit shipping to make sure we have the right country for tax calculation
        existingCcHelper.editShippingButton.tap()
        
        let shippingHelper = BSShippingScreenUITestHelper(app: app)
        setShippingDetails(shippingHelper: shippingHelper, shippingDetails: getDummyShippingDetails(countryCode: "US", stateCode: "MA"))
//        shippingHelper.setFieldValues(shippingDetails: getDummyShippingDetails(countryCode: "US", stateCode: "MA"), sdkRequest: sdkRequest)
        shippingHelper.closeKeyboard()
        let editShippingPayButton = checkReturningShopperDoneButton(isPayment: false)
        editShippingPayButton.tap()

        let payButton = checkPayButton()
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }
    
    func testShortReturningShopperExistingCcFlowWithEdit() {
        
        // full billing, with shipping, no email, new CC
        
        setUpForSdk(fullBilling: true, withShipping: true, withEmail: false, isReturningShopper: true, tapExistingCc: true)
        
        let existingCcHelper = waitForExistingCcScreen()
        
        existingCcHelper.editBillingButton.tap()
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        setBillingDetails(paymentHelper: paymentHelper, billingDetails: getDummyBillingDetails())
//        paymentHelper.setFieldValues(billingDetails: getDummyBillingDetails(), sdkRequest: sdkRequest)
        paymentHelper.closeKeyboard()
        let editBillingPayButton = checkReturningShopperDoneButton(isPayment: true)
        editBillingPayButton.tap()
        
        existingCcHelper.editShippingButton.tap()

        let shippingHelper = BSShippingScreenUITestHelper(app: app)
        setShippingDetails(shippingHelper: shippingHelper, shippingDetails: getDummyShippingDetails(countryCode: "IL", stateCode: nil))

//        shippingHelper.setFieldValues(shippingDetails: getDummyShippingDetails(countryCode: "IL", stateCode: nil), sdkRequest: sdkRequest)
        shippingHelper.closeKeyboard()
        let editShippingPayButton = checkReturningShopperDoneButton(isPayment: false)
        editShippingPayButton.tap()
        
        let payButton = checkPayButton()
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }

    // full billing, with shipping, check "shipping same as billing"
    
    func testShortReturningShopperNewCcFlow() {
        
        // no full billing, no shipping, no email, new CC
        
        setUpForSdk(fullBilling: false, withShipping: false, withEmail: false, isReturningShopper: true)

        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        fillBillingDetails(paymentHelper: paymentHelper, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails(countryCode: "US"), ignoreCountry: true)
        
        let elementsQuery = app.scrollViews.otherElements
        let textField = elementsQuery.element(matching: .any, identifier: "Name")
        if textField.exists {
            textField.tap()
            app.keyboards.buttons["Done"].tap()
        }
        
        let payButton = checkPayButton()
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }
    
    /* -------------------------------- New tests ---------------------------------------- */
    
    func testAllowCurrencyChange(){
        allowCurrencyChangeValidation(isEnabled: true)
    }
    
    func testNotAllowCurrencyChange(){
        allowCurrencyChangeValidation(isEnabled: false)
    }
    
    /**
     This test verifies that changing the currency while shipping is disabled
     changes the buy button as it should in payment screen.
     Also, it verifies that after changing to different currencies
     and back to the origin one, the amount remains the same
     */
    func testCurrencyChangesInPaymentScreen(){
//        testCurrencyChanges(withShipping: false)
    }
    
    /**
     This test verifies that changing the currency while shipping is enabled
     changes the buy button as it should in shipping screen.
     Also, it verifies that after changing to different currencies
     and back to the origin one, the amount remains the same
     */
    func testCurrencyChangesInShippingScreen(){
//        testCurrencyChanges(withShipping: true)
    }
    
    /* -------------------------------- New shopper views tests ---------------------------------------- */

    
    func testViewsFullBillingNoShippingNoEmail() {
        setUpForSdk(fullBilling: true, withShipping: false, withEmail: false)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)

        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")

        // check zip input field visibility according to different countries
        paymentHelper.checkZipVisibility(defaultCountry: defaultCountry, zipLabel: "Billing Zip")
        
        // check state input field visibility according to different countries
        paymentHelper.checkStateVisibility(defaultCountry: defaultCountry)

        // check pay button
        _ = checkPayButton()
        
        print("done")
    }
    
    func testViewsFullBillingNoShippingWithEmail() {
        setUpForSdk(fullBilling: true, withShipping: false, withEmail: true)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button
        _ = checkPayButton()
        
        // change country to USA to have state and zip
        paymentHelper.setCountry(countryCode: "US")
        
        // check trying to pay with empty fields
        paymentHelper.checkPayWithEmptyInputs(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, payButtonId: "PayButton", zipLabel: "Billing Zip")
        
        // check invalid cc line inputs
        paymentHelper.checkInvalidCCLineInputs()
        
        // check invalid billing inputs
        paymentHelper.checkInvalidInfoInputs(payButtonId: "PayButton")
        
        print("done")
    }
    
    func testViewsFullBillingWithShippingNoEmail() {
        setUpForSdk(fullBilling: true, withShipping: true, withEmail: false)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button when shipping same as billing is on
        _ = checkPayButton()
        
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        _ = checkPayButton()
        
        // continue to shipping screen
        let shippingHelper = gotoShippingScreen(paymentHelper: paymentHelper)
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        // check shipping pay button
        _ = checkShippingPayButton()
        
        shippingHelper.pressBackButton()
        
        print("done")
    }
    
    func testViewsFullBillingWithShippingWithEmail() {
        setUpForSdk(fullBilling: true, withShipping: true, withEmail: true)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button when shipping same as billing is on
        _ = checkPayButton()
        
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        _ = checkPayButton()
        
        // continue to shipping screen
        let shippingHelper = gotoShippingScreen(paymentHelper: paymentHelper)
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        // check shipping pay button
        _ = checkShippingPayButton()
        
        // fill in shipping details with country without shipping tax
        _ = fillShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "IL"))
        
        shippingHelper.pressBackButton()
        
        // verify that the billing info has been saved in payment screen (including error messages)
        paymentHelper.checkCcnComponentState(ccnShouldBeOpen: false, ccn: paymentHelper.getValidVisaCreditCardNumber(), last4digits: "1111", exp: "11/26", cvv: "333")
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: true)
        // check pay button- for shipping country with tax
        _ = checkPayButton()
        
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: false)
        // check pay button- for shipping country without tax
        _ = checkPayButton()
        
        // verify that the shipping info has been saved in shipping screen after choosing billing same as billing, and than rewind the choice.
        _ = gotoShippingScreen(paymentHelper: paymentHelper, fillInDetails: false)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        print("done")
    }
    
    func testViewsNoFullBillingNoShippingNoEmail() {
        setUpForSdk(fullBilling: false, withShipping: false, withEmail: false)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        paymentHelper.checkNewCCLineVisibilityAfterEnteringCCN()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button
        _ = checkPayButton()
        
        print("done")
    }
    
    func testViewsNoFullBillingNoShippingWithEmail() {
        setUpForSdk(fullBilling: false, withShipping: false, withEmail: true)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button
        _ = checkPayButton()
        
        print("done")
    }
    
    func testViewsNoFullBillingWithShippingNoEmail() {
        setUpForSdk(fullBilling: false, withShipping: true, withEmail: false)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button
        _ = checkPayButton()
        
        // continue to shipping screen
        let shippingHelper = gotoShippingScreen(paymentHelper: paymentHelper)
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        // check zip input field visibility according to different countries
        shippingHelper.checkZipVisibility(defaultCountry: defaultCountry, zipLabel: "Shipping Zip")
        
        // check state input field visibility according to different countries
        shippingHelper.checkStateVisibility(defaultCountry: defaultCountry)
        
        // check shipping pay button
        _ = checkShippingPayButton()
        
        // check trying to pay with empty fields
        shippingHelper.checkPayWithEmptyInputs(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, payButtonId: "ShippingPayButton", zipLabel: "Shipping Zip")
        
        // check invalid shipping inputs
        shippingHelper.checkInvalidInfoInputs(payButtonId: "ShippingPayButton")
        
        setShippingDetails(shippingHelper: shippingHelper, shippingDetails: getDummyShippingDetails(countryCode: "BR", stateCode: "RJ"))
        
        // go back and forward
        shippingHelper.pressBackButton()
        _ = gotoShippingScreen(paymentHelper: paymentHelper, fillInDetails: false)
        
        // verify info has been saved
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        print("done")
    }
    
    func testViewsNoFullBillingWithShippingWithEmail() {
        setUpForSdk(fullBilling: false, withShipping: true, withEmail: true)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button
        _ = checkPayButton()
        
        // continue to shipping screen
        let shippingHelper = gotoShippingScreen(paymentHelper: paymentHelper)
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        // check shipping pay button
        _ = checkShippingPayButton()
        
        print("done")
    }
    
    /* -------------------------------- New shopper end-to-end flow tests ---------------------------------------- */
    
    func testFlowFullBillingNoShippingNoEmail() {
        
        setUpForSdk(fullBilling: true, withShipping: false, withEmail: false)

        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)

        fillBillingDetails(paymentHelper: paymentHelper, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton()
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingNoEmail() {
        
        setUpForSdk(fullBilling: true, withShipping: true, withEmail: false)

        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        let _ = checkPayButton()

        fillBillingDetails(paymentHelper: paymentHelper, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        paymentHelper.closeKeyboard()
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: true)
        let _ = checkPayButton()
        
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: false)
        let payButton = checkPayButton()
        
        payButton.tap()
        waitForShippingScreen()
        
        let shippingPayButton = checkShippingPayButton()
        let shippingHelper = fillShippingDetails(shippingDetails: getDummyShippingDetails())
        let _ = checkShippingPayButton()
        
        shippingHelper.closeKeyboard()
        shippingPayButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingWithEmailNostate() {
        
        setUpForSdk(fullBilling: true, withShipping: true, withEmail: true)

        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "IL"
        billingDetails.state = nil
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        let _ = checkPayButton()
        
        fillBillingDetails(paymentHelper: paymentHelper, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: billingDetails)
        
        paymentHelper.closeKeyboard()
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: true)
        let _ = checkPayButton()
        
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: false)
        let payButton = checkPayButton()
        
        payButton.tap()
        waitForShippingScreen()
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GB"
        shippingDetails.state = nil

        let shippingPayButton = checkShippingPayButton()
        
        let shippingHelper = fillShippingDetails(shippingDetails: shippingDetails)
        let _ = checkShippingPayButton()
        
        shippingHelper.closeKeyboard()
        shippingPayButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingWithEmailNoZip() {
        
        setUpForSdk(fullBilling: true, withShipping: true, withEmail: true)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "GH"
        billingDetails.state = nil
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)

        fillBillingDetails(paymentHelper: paymentHelper, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: billingDetails)
        
        paymentHelper.closeKeyboard()
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: true)
        let _ = checkPayButton()
        
        setShippingSameAsBillingSwitch(paymentHelper: paymentHelper, shouldBeOn: false)
        let payButton = checkPayButton()
        
        payButton.tap()
        waitForShippingScreen()
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GH"
        shippingDetails.state = nil
        let shippingHelper = fillShippingDetails(shippingDetails: shippingDetails)
        let shippingPayButton = checkShippingPayButton()
        
        shippingHelper.closeKeyboard()
        shippingPayButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowFullBillingNoShippingWithEmail() {
        
        setUpForSdk(fullBilling: true, withShipping: false, withEmail: true)

        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        fillBillingDetails(paymentHelper: paymentHelper, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton()
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowNoFullBillingNoShippingWithEmail() {
        
        setUpForSdk(fullBilling: false, withShipping: false, withEmail: true)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)

        fillBillingDetails(paymentHelper: paymentHelper, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton()
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowNoFullBillingNoShippingNoEmail() {
        
        setUpForSdk(fullBilling: false, withShipping: false, withEmail: false)

        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)

        fillBillingDetails(paymentHelper: paymentHelper, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton()
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }
    
    func testShortestFlowNoFullBillingNoShippingNoEmail() {
        
        setUpForSdk(fullBilling: false, withShipping: false, withEmail: false)

        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        fillBillingDetails(paymentHelper: paymentHelper, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails(countryCode: "US"), ignoreCountry: true)
        
        paymentHelper.closeKeyboard()
        
        let payButton = checkPayButton()
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(expectedSuccessText: "Success!")
        
        print("done")
    }

    
    //------------------------------------ Helper functions ----------------------------
    
    // DemoApp helpers
    private func setMerchantCheckoutScreen(sdkRequest: BSSdkRequest, returningShopper: Bool = false) {
        
        // set new/returning shopper
        setSwitch(switchId: "ReturningShopperSwitch", isDesiredConfig: returningShopper, waitToExist: true, waitToDisappear: true)
        
        // set with Shipping switch = on
        setSwitch(switchId: "WithShippingSwitch", isDesiredConfig: sdkRequest.shopperConfiguration.withShipping, waitToExist: true)
        
        // set full billing switch = on
        setSwitch(switchId: "FullBillingSwitch", isDesiredConfig: sdkRequest.shopperConfiguration.fullBilling)
        
        // set with Email switch = on
        setSwitch(switchId: "WithEmailSwitch", isDesiredConfig: sdkRequest.shopperConfiguration.withEmail)
        
        // set with Email switch = on
        setSwitch(switchId: "allowCurrencyChangeSwitch", isDesiredConfig: sdkRequest.allowCurrencyChange)
        
        if let priceDetails = sdkRequest.priceDetails {
            
            // set amount text field value
            let amount = "\(priceDetails.amount ?? 0)"
            let amountField : XCUIElement = app.textFields["AmountField"]
            amountField.tap()
            amountField.doubleTap()
            amountField.typeText(amount)
        }
        
    }
    
    private func setSwitch(switchId: String, isDesiredConfig: Bool, waitToExist: Bool = false, waitToDisappear: Bool = false) {
        
        // set new/returning shopper
        let configSwitch = app.switches[switchId]
        if (waitToExist) {
            waitForElementToExist(element: configSwitch, waitTime: 140)
        }
        let configSwitchValue = (configSwitch.value as? String) ?? "0"
        if (configSwitchValue == "0" && isDesiredConfig) || (configSwitchValue == "1" && !isDesiredConfig) {
            configSwitch.tap()
            // wait for action to finish
            let coverView = app.otherElements.element(matching: .any, identifier: "CoverView")
            if (waitToDisappear) {
                waitForEllementToDisappear(element: coverView, waitTime: 30)
            }
        }
    }
    
    private func checkResult(expectedSuccessText: String) {
        
        let successLabel = app.staticTexts["SuccessLabel"]
        waitForElementToExist(element: successLabel, waitTime: 300)
        let labelText: String = successLabel.label
        assert(labelText == expectedSuccessText)
    } 
    
    private func checkReturningShopperDoneButton(isPayment: Bool) -> XCUIElement {
        let buttonId = isPayment ? "PayButton" : "ShippingPayButton"
        return checkAPayButton(buttonId: buttonId, expectedPayText: "Done")
    }
    
    // verify
    private func checkPayButton() -> XCUIElement {
        var expectedPayText = ""
        let country = shippingSameAsBilling ? sdkRequest.shopperConfiguration.billingDetails?.country : sdkRequest.shopperConfiguration.shippingDetails?.country
        let state = shippingSameAsBilling ? sdkRequest.shopperConfiguration.billingDetails?.state : sdkRequest.shopperConfiguration.shippingDetails?.state
        
        let taxPrecent = calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "")
        
        let taxAmount = purchaseAmount * (1+taxPrecent)
        
        if ((sdkRequest.shopperConfiguration.withShipping && isReturningShopper) ||
            (sdkRequest.shopperConfiguration.withShipping && shippingSameAsBilling)){
            expectedPayText = "Pay \(checkoutCurrency == "USD" ? "$" : checkoutCurrency  ?? "") \(taxAmount)"
        }
            
        else if (sdkRequest.shopperConfiguration.withShipping){
            expectedPayText = "Shipping >"

        }
        
        else{
            expectedPayText = "Pay \(checkoutCurrency == "USD" ? "$" : checkoutCurrency  ?? "") \(purchaseAmount ?? 0.0)"
        }
        
        return checkAPayButton(buttonId: "PayButton", expectedPayText: expectedPayText)
    }
    
    private func checkShippingPayButton() -> XCUIElement {
        
        let country = sdkRequest.shopperConfiguration.shippingDetails?.country
        let state = sdkRequest.shopperConfiguration.shippingDetails?.state
        
        let taxPrecent = calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "")
        
        let taxAmount = purchaseAmount * (1+taxPrecent)
        
        return checkAPayButton(buttonId: "ShippingPayButton", expectedPayText: "Pay \(checkoutCurrency == "USD" ? "$" : checkoutCurrency  ?? "") \(taxAmount)")
    }
    
    private func calcTaxFromCuntryAndState(countryCode: String, stateCode: String) -> Double {
        var taxPrecent = 0.0
        if (countryCode == "US"){
            taxPrecent = 0.05
            if (stateCode == "NY"){
                taxPrecent = 0.08
            }
        }
            
        else if (countryCode == "CA"){
            taxPrecent = 0.01
        }
        
        return taxPrecent
    }
    
    private func checkAPayButton(buttonId: String, expectedPayText: String) -> XCUIElement {
    
        let payButton = app.buttons[buttonId]
        
        XCTAssertTrue(payButton.exists, "\(buttonId) is not displayed")

        let payButtonText = payButton.label
//        XCTAssert(expectedPayText == payButtonText)
        XCTAssert(payButtonText.contains(expectedPayText), "Pay Button doesn't display the correct text. expected text: \(expectedPayText), actual text: \(payButtonText)")
        return payButton
    }
    
    private func tapPayButton(buttonId: String, screenHelper: BSCreditCardScreenUITestHelperBase){
        let aPayButton = app.buttons[buttonId]
        screenHelper.closeKeyboard()
        aPayButton.tap()
    }
    
    private func getDummyBillingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSBillingAddressDetails {
        
        let billingDetails = BSBillingAddressDetails(email: "shevie@gmail.com", name: "Shevie Chen", address: "58 somestreet", city : "somecity", zip : "4282300", country : countryCode, state : stateCode)
        return billingDetails
    }
    
    private func getDummyShippingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSShippingAddressDetails {
        
        let shippingDetails = BSShippingAddressDetails(name: "Funny Brice", address: "77 Rambla street", city : "Barcelona", zip : "4815", country : countryCode, state : stateCode)
        return shippingDetails
    }
    
    private func getDummyEditBillingDetails(countryCode: String? = "US", stateCode: String? = "NY") -> BSBillingAddressDetails {
        
        let billingDetails = BSBillingAddressDetails(email: "test@sdk.com", name: "La Fleur", address: "555 Broadway street", city : "New York", zip : "3abc 324a", country : countryCode, state : stateCode)
        return billingDetails
    }
    
    private func getDummyEditShippingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSShippingAddressDetails {
        
        let shippingDetails = BSShippingAddressDetails(name: "Janet Weiss", address: "75 some street", city : "Denton", zip : "162342", country : countryCode, state : stateCode)
        return shippingDetails
    }
    
    private func prepareSdkRequest(fullBilling: Bool, withShipping: Bool, withEmail: Bool, allowCurrencyChange: Bool = true) {

        let taxAmount = purchaseAmount * taxPercent // according to updateTax() in ViewController
        let priceDetails = BSPriceDetails(amount: purchaseAmount, taxAmount: taxAmount, currency: checkoutCurrency)
        let sdkRequest = BSSdkRequest(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: {_ in }, updateTaxFunc: nil)
        sdkRequest.shopperConfiguration.billingDetails = BSBillingAddressDetails()
        sdkRequest.shopperConfiguration.billingDetails?.country = defaultCountry
        sdkRequest.shopperConfiguration.shippingDetails = BSShippingAddressDetails()
        sdkRequest.shopperConfiguration.shippingDetails?.country = defaultCountry
        sdkRequest.allowCurrencyChange = allowCurrencyChange
        self.sdkRequest = sdkRequest
    }
    
    private func fillBillingDetails(paymentHelper: BSPaymentScreenUITestHelper, ccn: String, exp: String, cvv: String, billingDetails: BSBillingAddressDetails, ignoreCountry: Bool? = false) {
        
        // fill CC values
        paymentHelper.setCcDetails(isOpen: true, ccn: ccn, exp: exp, cvv: cvv)
        
        // make sure fields are shown according to configuration
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        setBillingDetails(paymentHelper: paymentHelper, billingDetails: billingDetails, ignoreCountry: ignoreCountry)
        
        // check that the values are in correctly
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
    }
    
    private func setBillingDetails(paymentHelper: BSPaymentScreenUITestHelper, billingDetails: BSBillingAddressDetails, ignoreCountry: Bool? = false){
        // fill field values
        paymentHelper.setFieldValues(billingDetails: billingDetails, sdkRequest: sdkRequest, ignoreCountry: ignoreCountry)
        
        sdkRequest.shopperConfiguration.billingDetails = billingDetails
    }
    
    private func fillShippingDetails(shippingDetails: BSShippingAddressDetails) -> BSShippingScreenUITestHelper {
        
        let shippingHelper = BSShippingScreenUITestHelper(app:app)
        
        // make sure fields are shown according to configuration
        sdkRequest.shopperConfiguration.shippingDetails = BSShippingAddressDetails()
        // This fails because name field contains hint "John Doe" and the XCT returns it as the field value
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        setShippingDetails(shippingHelper: shippingHelper, shippingDetails: shippingDetails)
        
        // check that the values are in correctly
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        return shippingHelper
    }
    
    private func setShippingDetails(shippingHelper: BSShippingScreenUITestHelper, shippingDetails: BSShippingAddressDetails){
        // fill field values
        shippingHelper.setFieldValues(shippingDetails: shippingDetails, sdkRequest: sdkRequest)
        
        sdkRequest.shopperConfiguration.shippingDetails = shippingDetails
    }
    
    private func gotoPaymentScreen(tapExistingCc: Bool = false){
        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)
        
        // set switches and amounts in merchant checkout screen
        setMerchantCheckoutScreen(sdkRequest: sdkRequest, returningShopper: isReturningShopper)
        
        // click "Checkout" button
        app.buttons["CheckoutButton"].tap()
        
        // wait for payment type screen to load
        
        let ccButton = paymentTypeHelper.getCcButtonElement()
        waitForElementToExist(element: ccButton, waitTime: 120)
        
        // make sure payment type buttons are visible
        paymentTypeHelper.checkPaymentTypes(expectedApplePay: true, expectedPayPal: true, expectedCC: true)
        
        if tapExistingCc {
            // click existing CC
            app.buttons["existingCc0"].tap()
            
        } else {
            // click New CC button
            app.buttons["CcButton"].tap()
        }
    }
    
    
    private func gotoShippingScreen(paymentHelper: BSPaymentScreenUITestHelper, fillInDetails: Bool = true) -> BSShippingScreenUITestHelper{
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        if (fillInDetails){
            fillBillingDetails(paymentHelper: paymentHelper, ccn: paymentHelper.getValidVisaCreditCardNumber(), exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        }
        
        paymentHelper.pressPayButton(payButtonId: "PayButton")
        
        waitForShippingScreen()
        
        return BSShippingScreenUITestHelper(app: app)
        
    }
    
    private func allowCurrencyChangeValidation(isEnabled: Bool){
        setUpForSdk(fullBilling: false, withShipping: true, withEmail: false, allowCurrencyChange: isEnabled)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        // check currency menu button visibility in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
        // check currency menu button visibility after opening country screen
        paymentHelper.setCountry(countryCode: "IL")

        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
        _ = gotoShippingScreen(paymentHelper: paymentHelper)
        
        pressBackButton()
        
        // check urrency menu button visibility back in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
    }
    
    private func testCurrencyChanges(withShipping: Bool){
        setUpForSdk(fullBilling: false, withShipping: withShipping, withEmail: false)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app, waitForElementToExistFunc: waitForElementToExist, waitForElementToDisappear: waitForEllementToDisappear)
        
        setAndUpdateCurrency(paymentHelper: paymentHelper, currencyName: "Israeli New Sheqel ILS", currencyCode: "ILS", oldCurrencyCode: checkoutCurrency)

        testCurrencyInPayButton(paymentHelper: paymentHelper, withShipping: withShipping, fillInDetails: true)
    
        setAndUpdateCurrency(paymentHelper: paymentHelper, currencyName: "US Dollar USD", currencyCode: "USD", oldCurrencyCode: "ILS")
        
        testCurrencyInPayButton(paymentHelper: paymentHelper, withShipping: withShipping, fillInDetails: false)

    }
    
    private func testCurrencyInPayButton(paymentHelper: BSPaymentScreenUITestHelper, withShipping: Bool, fillInDetails: Bool){
        if (withShipping){
            _ = gotoShippingScreen(paymentHelper: paymentHelper, fillInDetails: fillInDetails)
            _ = checkShippingPayButton()
            pressBackButton()
        }
            
        else {
            _ = checkPayButton()
        }
    }
    
    private func setAndUpdateCurrency(paymentHelper: BSPaymentScreenUITestHelper ,currencyName: String, currencyCode: String, oldCurrencyCode: String){
        paymentHelper.setCurrency(currencyName: currencyName)
        checkoutCurrency = currencyCode
        
        
        let currencies = BlueSnapSDK.getCurrencyRates()
        
        if (!(oldCurrencyCode == "USD")) {
            let conversionRateToUSD: Double = (currencies?.getCurrencyRateByCurrencyCode(code: oldCurrencyCode))!
            purchaseAmount = purchaseAmount / conversionRateToUSD;
        }
        
        let conversionRateFromUSD: Double = (currencies?.getCurrencyRateByCurrencyCode(code: currencyCode))!
        
        purchaseAmount = purchaseAmount * conversionRateFromUSD;
        
    }
    
    private func setShippingSameAsBillingSwitch(paymentHelper: BSPaymentScreenUITestHelper, shouldBeOn: Bool){
        paymentHelper.closeKeyboard()
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: shouldBeOn)
        shippingSameAsBilling = shouldBeOn
    }
    
    func pressBackButton() {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
    private func waitForExistingCcScreen() -> BSExistingCcScreenUITestHelper {
        
        let existingCcHelper = BSExistingCcScreenUITestHelper(app:app)
        waitForElementToExist(element: existingCcHelper.billingNameLabel, waitTime: 60)
        return existingCcHelper
    }
    
    private func waitForPaymentScreen() {

        let payButton = app.buttons["PayButton"]
        waitForElementToExist(element: payButton, waitTime: 60)
    }
    
    private func waitForShippingScreen() {

        let payButton = app.buttons["ShippingPayButton"]
        waitForElementToExist(element: payButton, waitTime: 60)
    }
    
    private func waitForElementToExist(element: XCUIElement, waitTime: TimeInterval) {

        let exists = NSPredicate(format: "exists == 1")
        let ex: XCTestExpectation = expectation(for: exists, evaluatedWith: element)
        wait(for: [ex], timeout: waitTime)
//        waitForExpectations(timeout: waitTime, handler: { error in
//            NSLog("Finished waiting")
//        })
    }
    
    private func waitForEllementToDisappear(element: XCUIElement, waitTime: TimeInterval) {

        let exists = NSPredicate(format: "exists == 0")
        let ex: XCTestExpectation = expectation(for: exists, evaluatedWith: element)
        wait(for: [ex], timeout: waitTime)
    }
    
}

//extension XCTestCase {
//    
//    func wait(for duration: TimeInterval) {
//        let waitExpectation = expectation(description: "Waiting")
//        
//        let when = DispatchTime.now() + duration
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            waitExpectation.fulfill()
//        }
//        
//        // We use a buffer here to avoid flakiness with Timer on CI
//        waitForExpectations(timeout: duration + 0.5)
//    }
//}
