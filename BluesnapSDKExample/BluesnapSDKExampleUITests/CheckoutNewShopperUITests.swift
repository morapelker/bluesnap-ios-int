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
//@testable import BluesnapSDKIntegrationTests //TODO: make it work

class CheckoutNewShopperUITests: CheckoutBaseTester {
    
    /* -------------------------------- Returning shopper tests ---------------------------------------- */

    // full billing, with shipping, check "shipping same as billing"
    
//    func testShortReturningShopperNewCcFlow() {
//
//        // no full billing, no shipping, no email, new CC
//
//        setUpForSdk(fullBilling: false, withShipping: false, withEmail: false, isReturningShopper: true)
//
//        fillBillingDetails(ccn: BSUITestUtils.getValidVisaCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: getDummyBillingDetails(countryCode: "US"), ignoreCountry: true)
//
//        let elementsQuery = app.scrollViews.otherElements
//        let textField = elementsQuery.element(matching: .any, identifier: "Name")
//        if textField.exists {
//            textField.tap()
//            app.keyboards.buttons["Done"].tap()
//        }
//
//        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: shippingSameAsBilling)
//        paymentHelper.pressPayButton()
//
//        checkResult(expectedSuccessText: "Success!")
//
//        print("done")
//    }

    /* -------------------------------- New shopper views tests ---------------------------------------- */
    
    func testAllowCurrencyChange(){
        allowCurrencyChangeValidation(isEnabled: true)
    }
    
    func testNotAllowCurrencyChange(){
        allowCurrencyChangeValidation(isEnabled: false)
    }
    
    //TODO: fix these two!!
    
    /**
     This test verifies that changing the currency while shipping is disabled
     changes the buy button as it should in payment screen.
     Also, it verifies that after changing to different currencies
     and back to the origin one, the amount remains the same
     */
//    func testCurrencyChangesInPaymentScreen(){
//        testCurrencyChanges(withShipping: false)
//    }
    
    /**
     This test verifies that changing the currency while shipping is enabled
     changes the buy button as it should in shipping screen.
     Also, it verifies that after changing to different currencies
     and back to the origin one, the amount remains the same
     */
//    func testCurrencyChangesInShippingScreen(){
//        testCurrencyChanges(withShipping: true)
//    }

    
    func testViewsFullBillingNoShippingNoEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: false, withEmail: false)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)

        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check zip input field visibility according to different countries
        paymentHelper.checkZipVisibility(defaultCountry: defaultCountry, zipLabel: "Billing Zip")
        
        // check state input field visibility according to different countries
        paymentHelper.checkStateVisibility(defaultCountry: defaultCountry)

        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)
        
    }
    
    func testViewsFullBillingNoShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: false, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // change country to USA to have state and zip
        paymentHelper.setCountry(countryCode: "US")
        
        // check trying to pay with empty fields
        paymentHelper.checkPayWithEmptyInputs(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, payButtonId: "PayButton", zipLabel: "Billing Zip")
        
        // check invalid cc line inputs
        paymentHelper.checkInvalidCCLineInputs()
        
        // check invalid billing inputs
        paymentHelper.checkInvalidInfoInputs(payButtonId: "PayButton")
        
    }
    
    func testViewsFullBillingWithShippingNoEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: false)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check pay button when shipping same as billing is on
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest)

        BSUITestUtils.pressBackButton(app: app)

    }
    
    func testViewsFullBillingWithShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check pay button when shipping same as billing is on
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest)

        // fill in shipping details with country without shipping tax
        fillShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "IL"))
        
        BSUITestUtils.pressBackButton(app: app)

        // verify that the billing info has been saved in payment screen (including error messages)
        paymentHelper.checkCcnComponentState(ccnShouldBeOpen: false, ccn: BSUITestUtils.getValidVisaCreditCardNumber(), last4digits: "1111", exp: "11/26", cvv: "333")
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        setShippingSameAsBillingSwitch(shouldBeOn: true)
        // check pay button- for shipping country with tax
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        setShippingSameAsBillingSwitch(shouldBeOn: false)
        // check pay button- for shipping country without tax
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // verify that the shipping info has been saved in shipping screen after choosing billing same as billing, and than rewind the choice.
        gotoShippingScreen(fillInDetails: false)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
    }
    
    func testViewsNoFullBillingNoShippingNoEmail() {
        setUpForCheckoutSdk(fullBilling: false, withShipping: false, withEmail: false)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        paymentHelper.checkNewCCLineVisibilityAfterEnteringCCN()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

    }
    
    func testViewsNoFullBillingNoShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: false, withShipping: false, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

    }
    
    func testViewsNoFullBillingWithShippingNoEmail() {
        setUpForCheckoutSdk(fullBilling: false, withShipping: true, withEmail: false)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check zip input field visibility according to different countries
        shippingHelper.checkZipVisibility(defaultCountry: defaultCountry, zipLabel: "Shipping Zip")
        
        // check state input field visibility according to different countries
        shippingHelper.checkStateVisibility(defaultCountry: defaultCountry)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest)

        // check trying to pay with empty fields
        shippingHelper.checkPayWithEmptyInputs(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, payButtonId: "ShippingPayButton", zipLabel: "Shipping Zip")
        
        // check invalid shipping inputs
        shippingHelper.checkInvalidInfoInputs(payButtonId: "ShippingPayButton")
        
        setShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "BR", stateCode: "RJ"))
        
        // go back and forward
        BSUITestUtils.pressBackButton(app: app)
        gotoShippingScreen(fillInDetails: false)
        
        // verify info has been saved
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
    }
    
    func testViewsNoFullBillingWithShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: false, withShipping: true, withEmail: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check pay button
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)

        // continue to shipping screen
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest)

    }
    
    /* -------------------------------- New shopper end-to-end flow tests ---------------------------------------- */
    
    func newCardBasicCheckoutFlow(fullBilling: Bool, withShipping: Bool, withEmail: Bool, shippingSameAsBilling: Bool = false, hideStoreCardSwitch: Bool = false, storeCard: Bool = false) {

        setUpForCheckoutSdk(fullBilling: fullBilling, withShipping: withShipping, withEmail: withEmail, hideStoreCardSwitch: hideStoreCardSwitch)
        
        //TODO: add store card visibility check
        
        newCardBasicFillInInfoAndPay(shippingSameAsBilling: shippingSameAsBilling, storeCard: storeCard)
        
        checkResult(expectedSuccessText: "Success!")
        
        let shopperIdLabel = app.staticTexts["ShopperIdLabel"]
        waitForElementToExist(element: shopperIdLabel, waitTime: 300)
        
        var shopperId: String = shopperIdLabel.label
        let range = shopperId.startIndex..<shopperId.index(shopperId.startIndex, offsetBy: 12)

        shopperId.removeSubrange(range)
        
        let semaphore = DispatchSemaphore(value: 0)

        DemoAPIHelper.retrieveVaultedShopper(vaultedShopperId: shopperId, completion: {
            isSuccess, data in
            XCTAssert(isSuccess, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            let error = BSUITestUtils.checkRetrieveVaultedShopperResponse(responseBody: data!, sdkRequest: self.sdkRequest, cardStored: storeCard, expectedCreditCardInfo: [("1111", "VISA", "11","2026")], shippingSameAsBilling: shippingSameAsBilling)

            XCTAssertNil(error, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            semaphore.signal()
        })
        
        semaphore.wait()

    }
    
    func newCardBasicFillInInfoAndPay(shippingSameAsBilling: Bool = false, storeCard: Bool = false) {
        // fill in info in payment screen and continue to shipping or paying
        fillBillingDetails(ccn: BSUITestUtils.getValidVisaCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: getDummyBillingDetails())
        
        if (storeCard){
            setStoreCardSwitch(shouldBeOn: storeCard)
        }
        
        // continue to shipping it's required and fill in info in shipping screen
        if (sdkRequest.shopperConfiguration.withShipping && !shippingSameAsBilling){
            if (isShippingSameAsBillingOn){
                setShippingSameAsBillingSwitch(shouldBeOn: false)
            }
            gotoShippingScreen(fillInDetails: false)
            fillShippingDetails(shippingDetails: getDummyShippingDetails())
            shippingHelper.pressPayButton()
        }
            
        else{
            paymentHelper.pressPayButton()
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

        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: true)

        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "IL"
        billingDetails.state = nil
        
        fillBillingDetails(ccn: BSUITestUtils.getValidVisaCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: billingDetails)
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        paymentHelper.pressPayButton()

        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GB"
        shippingDetails.state = nil
        
        fillShippingDetails(shippingDetails: shippingDetails)
        
        shippingHelper.pressPayButton()

        checkResult(expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    // TODO: do we need this?
    func testFlowFullBillingWithShippingWithEmailNoZip() {

        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: true)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "GH"
        billingDetails.state = nil

        fillBillingDetails(ccn: BSUITestUtils.getValidVisaCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: billingDetails)
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        paymentHelper.pressPayButton()

        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GH"
        shippingDetails.state = nil
        fillShippingDetails(shippingDetails: shippingDetails)
        
        shippingHelper.pressPayButton()

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
    
    func testFlowStoreCardInServer() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true, storeCard: true)
    }
    
    func testFlowHideStoreCardSwitch(){
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true, hideStoreCardSwitch: true)
    }
    
    //------------------------------------ Helper functions ----------------------------
    
    // DemoApp helpers
    
    
    // verify
//    private func checkPayButton() {
//        var expectedPayText = ""
//        let country = shippingSameAsBilling ? sdkRequest.shopperConfiguration.billingDetails?.country : sdkRequest.shopperConfiguration.shippingDetails?.country
//        let state = shippingSameAsBilling ? sdkRequest.shopperConfiguration.billingDetails?.state : sdkRequest.shopperConfiguration.shippingDetails?.state
//
////        let taxPrecent = calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "")
//
//        let includeTaxAmount = BSUITestUtils.calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "", purchaseAmount: purchaseAmount)
//
//        if ((sdkRequest.shopperConfiguration.withShipping && isReturningShopper) ||
//            (sdkRequest.shopperConfiguration.withShipping && shippingSameAsBilling)){
//            expectedPayText = "Pay \(checkoutCurrency == "USD" ? "$" : checkoutCurrency  ?? "") \(includeTaxAmount)"
//        }
//
//        else if (sdkRequest.shopperConfiguration.withShipping){
//            expectedPayText = "Shipping >"
//
//        }
//
//        else{
//            expectedPayText = "Pay \(checkoutCurrency == "USD" ? "$" : checkoutCurrency  ?? "") \(purchaseAmount ?? 0.0)"
//        }
//
//        BSUITestUtils.checkAPayButton(app: app, buttonId: "PayButton", expectedPayText: expectedPayText)
//    }
    
//    private func checkShippingPayButton() {
//        
//        let country = sdkRequest.shopperConfiguration.shippingDetails?.country
//        let state = sdkRequest.shopperConfiguration.shippingDetails?.state
//        
////        let taxPrecent = calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "")
//        
//        let includeTaxAmount = BSUITestUtils.calcTaxFromCuntryAndState(countryCode: country ?? "", stateCode: state ?? "", purchaseAmount: purchaseAmount)
//        
//        
//        BSUITestUtils.checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Pay \(checkoutCurrency == "USD" ? "$" : checkoutCurrency  ?? "") \(includeTaxAmount)")
//    }

    
    private func allowCurrencyChangeValidation(isEnabled: Bool){
        setUpForCheckoutSdk(fullBilling: false, withShipping: true, withEmail: false, allowCurrencyChange: isEnabled)
        
        // check currency menu button visibility in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
        // check currency menu button visibility after opening country screen
        paymentHelper.setCountry(countryCode: "US")

        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
        gotoShippingScreen()
        
        BSUITestUtils.pressBackButton(app: app)

        // check urrency menu button visibility back in payment screen
        paymentHelper.checkMenuButtonEnabled(expectedEnabled: isEnabled)
        
    }
    
    private func testCurrencyChanges(withShipping: Bool){
        setUpForCheckoutSdk(fullBilling: false, withShipping: withShipping, withEmail: false)
        
        setAndUpdateCurrency(currencyName: "Israeli New Sheqel ILS", newCurrencyCode: "ILS", oldCurrencyCode: checkoutCurrency)

        testCurrencyInPayButton(withShipping: withShipping, fillInDetails: true)
    
        setAndUpdateCurrency(currencyName: "US Dollar USD", newCurrencyCode: "USD", oldCurrencyCode: "ILS")
        
        testCurrencyInPayButton(withShipping: withShipping, fillInDetails: false)

    }
    
    private func testCurrencyInPayButton(withShipping: Bool, fillInDetails: Bool){
        if (withShipping){
            gotoShippingScreen(fillInDetails: fillInDetails)
//            _ = checkShippingPayButton()
            BSUITestUtils.pressBackButton(app: app)
        }
            
        else {
//            _ = checkPayButton()
        }
    }
    
    private func setAndUpdateCurrency(currencyName: String, newCurrencyCode: String, oldCurrencyCode: String){
        paymentHelper.setCurrency(currencyName: currencyName)
        sdkRequest.priceDetails.currency = newCurrencyCode
        
//        var purchaseAmount = sdkRequest.priceDetails.amount.doubleValue
        
//        let currencies = BlueSnapSDK.getCurrencyRates()
//
//        if (!(oldCurrencyCode == "USD")) {
//            let conversionRateToUSD: Double = (currencies?.getCurrencyRateByCurrencyCode(code: oldCurrencyCode))!
//            purchaseAmount = purchaseAmount / conversionRateToUSD;
//        }
//
//        let conversionRateFromUSD: Double = (currencies?.getCurrencyRateByCurrencyCode(code: currencyCode))!
//
//        purchaseAmount = purchaseAmount * conversionRateFromUSD;
        
        
    }
    
    private func waitForExistingCcScreen() -> BSExistingCcScreenUITestHelper {
        
        let existingCcHelper = BSExistingCcScreenUITestHelper(app:app)
        waitForElementToExist(element: existingCcHelper.billingNameLabel, waitTime: 60)
        return existingCcHelper
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
