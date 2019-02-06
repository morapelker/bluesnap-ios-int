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

class CheckoutNewShopperUITests: CheckoutBaseTester {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
//        app.terminate()
        
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
        
        setShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "US", stateCode: "MA"))
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
        
        setBillingDetails(billingDetails: getDummyBillingDetails())
//        paymentHelper.setFieldValues(billingDetails: getDummyBillingDetails(), sdkRequest: sdkRequest)
        paymentHelper.closeKeyboard()
        let editBillingPayButton = checkReturningShopperDoneButton(isPayment: true)
        editBillingPayButton.tap()
        
        existingCcHelper.editShippingButton.tap()

        setShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "IL", stateCode: nil))

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
        
        fillBillingDetails(ccn: paymentHelper.getValidVisaCreditCardNumber(), exp: paymentHelper.getValidExpDate(), cvv: paymentHelper.getValidCvvNumber(), billingDetails: getDummyBillingDetails(countryCode: "US"), ignoreCountry: true)
        
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
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button when shipping same as billing is on
        _ = checkPayButton()
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        _ = checkPayButton()
        
        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        // check shipping pay button
        _ = checkShippingPayButton()
        
        shippingHelper.pressBackButton()
        
        print("done")
    }
    
    func testViewsFullBillingWithShippingWithEmail() {
        setUpForSdk(fullBilling: true, withShipping: true, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button when shipping same as billing is on
        _ = checkPayButton()
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        _ = checkPayButton()
        
        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        // check shipping pay button
        _ = checkShippingPayButton()
        
        // fill in shipping details with country without shipping tax
        fillShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "IL"))
        
        shippingHelper.pressBackButton()
        
        // verify that the billing info has been saved in payment screen (including error messages)
        paymentHelper.checkCcnComponentState(ccnShouldBeOpen: false, ccn: paymentHelper.getValidVisaCreditCardNumber(), last4digits: "1111", exp: "11/26", cvv: "333")
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        setShippingSameAsBillingSwitch(shouldBeOn: true)
        // check pay button- for shipping country with tax
        _ = checkPayButton()
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        // check pay button- for shipping country without tax
        _ = checkPayButton()
        
        // verify that the shipping info has been saved in shipping screen after choosing billing same as billing, and than rewind the choice.
        gotoShippingScreen(fillInDetails: false)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        print("done")
    }
    
    func testViewsNoFullBillingNoShippingNoEmail() {
        setUpForSdk(fullBilling: false, withShipping: false, withEmail: false)
        
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
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button
        _ = checkPayButton()
        
        // continue to shipping screen
        gotoShippingScreen()
        
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
        
        setShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "BR", stateCode: "RJ"))
        
        // go back and forward
        shippingHelper.pressBackButton()
        gotoShippingScreen(fillInDetails: false)
        
        // verify info has been saved
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        print("done")
    }
    
    func testViewsNoFullBillingWithShippingWithEmail() {
        setUpForSdk(fullBilling: false, withShipping: true, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        // check pay button
        _ = checkPayButton()
        
        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        
        // check shipping pay button
        _ = checkShippingPayButton()
        
        print("done")
    }
    
    /* -------------------------------- New shopper end-to-end flow tests ---------------------------------------- */
    
    func newCardBasicCheckoutFlow(fullBilling: Bool, withShipping: Bool, withEmail: Bool, shippingSameAsBilling: Bool = false) {
        
        setUpForSdk(fullBilling: fullBilling, withShipping: withShipping, withEmail: withEmail)
        
        newCardBasicFillInInfoAndPay(shippingSameAsBilling: shippingSameAsBilling)
        
        checkResult(expectedSuccessText: "Success!")
        
        let shopperIdLabel = app.staticTexts["ShopperIdLabel"]
        waitForElementToExist(element: shopperIdLabel, waitTime: 300)
        
        var shopperId: String = shopperIdLabel.label
        let range = shopperId.startIndex..<shopperId.index(shopperId.startIndex, offsetBy: 12)

        shopperId.removeSubrange(range)
        
        //TODO: fix this!!!!
        let semaphore = DispatchSemaphore(value: 0)

        DemoAPIHelper.retrieveVaultedShopper(vaultedShopperId: shopperId, completion: {
            isSuccess, data in
            XCTAssert(isSuccess, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            let error = BSUITestUtils.checkRetrieveVaultedShopperResponse(responseBody: data!, sdkRequest: self.sdkRequest, expectedCreditCardInfo: ("1111", "VISA", "11","2026"), shippingSameAsBilling: shippingSameAsBilling)

            XCTAssertNil(error, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            semaphore.signal()
        })
        
        semaphore.wait()

        print("done")
    }
    
    func newCardBasicFillInInfoAndPay(shippingSameAsBilling: Bool = false) {
        // fill in info in payment screen and continue to shipping or paying
        fillBillingDetails(ccn: paymentHelper.getValidVisaCreditCardNumber(), exp: paymentHelper.getValidExpDate(), cvv: paymentHelper.getValidCvvNumber(), billingDetails: getDummyBillingDetails())
        
        // continue to shipping it's required and fill in info in shipping screen
        if (sdkRequest.shopperConfiguration.withShipping && !shippingSameAsBilling){
            if (sdkRequest.shopperConfiguration.fullBilling){
                setShippingSameAsBillingSwitch(shouldBeOn: false)
            }
            gotoShippingScreen(fillInDetails: false)
            fillShippingDetails(shippingDetails: getDummyShippingDetails())
            shippingHelper.pressPayButton(payButtonId: "ShippingPayButton")
        }
            
        else{
            paymentHelper.pressPayButton(payButtonId: "PayButton")
        }
    }
    
    func testFlowFullBillingNoShippingNoEmail() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: false, withEmail: false)
    }
    
    func testFlowFullBillingNoShippingWithEmail() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: false, withEmail: true)
    }
    
    func testFlowFullBillingWithShippingNoEmail() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: false)
    }
    
    func testFlowFullBillingWithShippingWithEmail() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true)
    }
    
    func testFlowShippingSameAsBilling() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true, shippingSameAsBilling: true)
    }
    
    // TODO: do we need this?
    func testFlowFullBillingWithShippingWithEmailNostate() {
        
        setUpForSdk(fullBilling: true, withShipping: true, withEmail: true)

        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "IL"
        billingDetails.state = nil
        
        fillBillingDetails(ccn: paymentHelper.getValidVisaCreditCardNumber(), exp: paymentHelper.getValidExpDate(), cvv: paymentHelper.getValidCvvNumber(), billingDetails: billingDetails)
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        paymentHelper.pressPayButton(payButtonId: "PayButton")
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GB"
        shippingDetails.state = nil
        
        fillShippingDetails(shippingDetails: shippingDetails)
        
        shippingHelper.pressPayButton(payButtonId: "ShippingPayButton")
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    // TODO: do we need this?
    func testFlowFullBillingWithShippingWithEmailNoZip() {
        
        setUpForSdk(fullBilling: true, withShipping: true, withEmail: true)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "GH"
        billingDetails.state = nil

        fillBillingDetails(ccn: paymentHelper.getValidVisaCreditCardNumber(), exp: paymentHelper.getValidExpDate(), cvv: paymentHelper.getValidCvvNumber(), billingDetails: billingDetails)
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        paymentHelper.pressPayButton(payButtonId: "PayButton")
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GH"
        shippingDetails.state = nil
        fillShippingDetails(shippingDetails: shippingDetails)
        
        shippingHelper.pressPayButton(payButtonId: "ShippingPayButton")
        
        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowNoFullBillingNoShippingNoEmail() {
        newCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: false)
    }
    
    func testFlowNoFullBillingNoShippingWithEmail() {
        newCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: true)
    }
    
    func testFlowNoFullBillingWithShippingNoEmail() {
        newCardBasicCheckoutFlow(fullBilling: false, withShipping: true, withEmail: false)
    }
    
    func testFlowNoFullBillingWithShippingWithEmail() {
        newCardBasicCheckoutFlow(fullBilling: false, withShipping: true, withEmail: true)
    }
    
    //------------------------------------ Helper functions ----------------------------
    
    // DemoApp helpers
    
    
    
    private func checkReturningShopperDoneButton(isPayment: Bool) -> XCUIElement {
        let buttonId = isPayment ? "PayButton" : "ShippingPayButton"
        return checkAPayButton(buttonId: buttonId, expectedPayText: "Done")
    }
    
    // verify
    private func checkPayButton() -> XCUIElement {
        var expectedPayText = ""
        let country = shippingSameAsBilling ? sdkRequest.shopperConfiguration.billingDetails?.country : sdkRequest.shopperConfiguration.shippingDetails?.country
        let state = shippingSameAsBilling ? sdkRequest.shopperConfiguration.billingDetails?.state : sdkRequest.shopperConfiguration.shippingDetails?.state
        
//        let taxPrecent = calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "")
        
        let includeTaxAmount = calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "")

        if ((sdkRequest.shopperConfiguration.withShipping && isReturningShopper) ||
            (sdkRequest.shopperConfiguration.withShipping && shippingSameAsBilling)){
            expectedPayText = "Pay \(checkoutCurrency == "USD" ? "$" : checkoutCurrency  ?? "") \(includeTaxAmount)"
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
        
//        let taxPrecent = calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "")
        
        let includeTaxAmount = calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "")
        
        return checkAPayButton(buttonId: "ShippingPayButton", expectedPayText: "Pay \(checkoutCurrency == "USD" ? "$" : checkoutCurrency  ?? "") \(includeTaxAmount)")
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
        
        let includeTaxAmount = purchaseAmount * (1+taxPrecent)
        
        return includeTaxAmount
    }
    
    private func checkAPayButton(buttonId: String, expectedPayText: String) -> XCUIElement {
    
        let payButton = app.buttons[buttonId]
        
        XCTAssertTrue(payButton.exists, "\(buttonId) is not displayed")

        let payButtonText = payButton.label
//        XCTAssert(expectedPayText == payButtonText)
        XCTAssert(payButtonText.contains(expectedPayText), "Pay Button doesn't display the correct text. expected text: \(expectedPayText), actual text: \(payButtonText)")
        return payButton
    }

    
    private func gotoShippingScreen(fillInDetails: Bool = true) {
        
        if (fillInDetails){
            fillBillingDetails(ccn: paymentHelper.getValidVisaCreditCardNumber(), exp: paymentHelper.getValidExpDate(), cvv: paymentHelper.getValidCvvNumber(), billingDetails: getDummyBillingDetails())
        }
        
        paymentHelper.pressPayButton(payButtonId: "PayButton")
        
        waitForShippingScreen()
    }
    
    private func allowCurrencyChangeValidation(isEnabled: Bool){
        setUpForSdk(fullBilling: false, withShipping: true, withEmail: false, allowCurrencyChange: isEnabled)
        
        // check currency menu button visibility in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
        // check currency menu button visibility after opening country screen
        paymentHelper.setCountry(countryCode: "US")

        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
        gotoShippingScreen()
        
        pressBackButton()
        
        // check urrency menu button visibility back in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
    }
    
    private func testCurrencyChanges(withShipping: Bool){
        setUpForSdk(fullBilling: false, withShipping: withShipping, withEmail: false)
        
        setAndUpdateCurrency(currencyName: "Israeli New Sheqel ILS", currencyCode: "ILS", oldCurrencyCode: checkoutCurrency)

        testCurrencyInPayButton(withShipping: withShipping, fillInDetails: true)
    
        setAndUpdateCurrency(currencyName: "US Dollar USD", currencyCode: "USD", oldCurrencyCode: "ILS")
        
        testCurrencyInPayButton(withShipping: withShipping, fillInDetails: false)

    }
    
    private func testCurrencyInPayButton(withShipping: Bool, fillInDetails: Bool){
        if (withShipping){
            gotoShippingScreen(fillInDetails: fillInDetails)
            _ = checkShippingPayButton()
            pressBackButton()
        }
            
        else {
            _ = checkPayButton()
        }
    }
    
    private func setAndUpdateCurrency(currencyName: String, currencyCode: String, oldCurrencyCode: String){
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
    
    private func setShippingSameAsBillingSwitch(shouldBeOn: Bool){
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
