//
// Created by Sivani on 2019-02-18.
// Copyright (c) 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest

class ChoosePaymentMethodUITests: UIBaseTester {

    internal var existingCcHelper: BSExistingCcScreenUITestHelper!
    internal var vaultedShopperId: String!

    internal func setUpForChoosePaymentMethodSdk(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false) {

        // initialize required helpers
        if (tapExistingCc) {
            existingCcHelper = BSExistingCcScreenUITestHelper(app: app)
        }

//        printShopperDiscription(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)

        let semaphore = DispatchSemaphore(value: 0)

        DemoAPIHelper.createVaultedShopper(fullBilling: shopperWithFullBilling, withEmail: shopperWithEmail, withShipping: shopperWithShipping, billingInfo: getDummyBillingDetails(), shippingInfo: getDummyShippingDetails(), creditCard: (Int(BSUITestUtils.getValidExpYear()) ?? 2026, Int(BSUITestUtils.getValidCvvNumber()) ?? 333, BSUITestUtils.getValidExpMonth(), BSUITestUtils.getValidVisaCreditCardNumberWithoutSpaces()), completion: { shopperId, error in
            if let shopperId_ = shopperId {
                self.vaultedShopperId = shopperId_
                semaphore.signal()
            }
        })

        semaphore.wait()

        super.setUpForSdk(fullBilling: checkoutFullBilling, withShipping: checkoutWithShipping, withEmail: checkoutWithEmail, isReturningShopper: true, shopperId: vaultedShopperId)

        setShopperDetailsInSdkRequest(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)

        // start checkout
        gotoPaymentScreen(shopperId: vaultedShopperId, tapExistingCc: tapExistingCc, checkExistingCcLine: checkExistingCcLine)
    }

    func setShopperDetailsInSdkRequest(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){

        // set billing/shipping info
        sdkRequest.shopperConfiguration.billingDetails = BSUITestUtils.getDummyBillingDetails()
        if (!shopperWithEmail){
            sdkRequest.shopperConfiguration.billingDetails?.email = nil
        }

        if (!shopperWithFullBilling){
            sdkRequest.shopperConfiguration.billingDetails?.address = nil
            sdkRequest.shopperConfiguration.billingDetails?.city = nil
            sdkRequest.shopperConfiguration.billingDetails?.state = nil
        }

        if(shopperWithShipping){
            sdkRequest.shopperConfiguration.shippingDetails = BSUITestUtils.getDummyShippingDetails()
        }

        else{
            sdkRequest.shopperConfiguration.shippingDetails?.name = sdkRequest.shopperConfiguration.billingDetails?.name
            sdkRequest.shopperConfiguration.shippingDetails?.zip = sdkRequest.shopperConfiguration.billingDetails?.zip
            sdkRequest.shopperConfiguration.shippingDetails?.country = sdkRequest.shopperConfiguration.billingDetails?.country
            if (sdkRequest.shopperConfiguration.fullBilling){
                sdkRequest.shopperConfiguration.shippingDetails?.address = sdkRequest.shopperConfiguration.billingDetails?.address
                sdkRequest.shopperConfiguration.shippingDetails?.city = sdkRequest.shopperConfiguration.billingDetails?.city
                sdkRequest.shopperConfiguration.shippingDetails?.state = sdkRequest.shopperConfiguration.billingDetails?.state
            }
        }

    }

    private func gotoPaymentScreen(shopperId: String? = nil, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false) {
        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)

        // click "Checkout" button
        app.buttons["ChooseButton"].tap()

        // wait for payment type screen to load

        let ccButton = paymentTypeHelper.getCcButtonElement()
        waitForElementToExist(element: ccButton, waitTime: 120)

        // make sure payment type buttons are visible
        paymentTypeHelper.checkPaymentTypes(expectedApplePay: true, expectedPayPal: true, expectedCC: true)

        if tapExistingCc {
            if (checkExistingCcLine) {// check existing CC line
                paymentTypeHelper.checkExistingCCLine(index: 0, expectedLastFourDigits: "1111", expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
            }

            // click existing CC
            app.buttons["existingCc0"].tap()

        } else {
            // click New CC button
            app.buttons["CcButton"].tap()
        }
    }


    /* -------------------------------- Choose Payment Method Common tests ---------------------------------------- */


    func chooseNewCardPaymentMethodFlow(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool) {

        setUpForChoosePaymentMethodSdk(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping)

        newCardBasicFillInInfoAndPay()

        let semaphore = DispatchSemaphore(value: 0)

        DemoAPIHelper.retrieveVaultedShopper(vaultedShopperId: vaultedShopperId, completion: {
            isSuccess, data in
            XCTAssert(isSuccess, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            let error = BSUITestUtils.checkRetrieveVaultedShopperResponse(responseBody: data!, sdkRequest: self.sdkRequest, expectedCreditCardInfo: (BSUITestUtils.getValidMCLast4Digits(), "MASTERCARD", BSUITestUtils.getValidExpMonth(),BSUITestUtils.getValidExpYear()))

            XCTAssertNil(error, "error: \(String(describing: "Retrieve Vaulted Shopper failed"))")

            semaphore.signal()
        })

        semaphore.wait()

        print("done")
    }

    func newCardBasicFillInInfoAndPay() {
        // fill in info in payment screen and continue to shipping or paying
        fillBillingDetails(ccn: BSUITestUtils.getValidMCCreditCardNumber(), exp: BSUITestUtils.getValidExpDate(), cvv: BSUITestUtils.getValidCvvNumber(), billingDetails: getDummyBillingDetails())

        // continue to shipping it's required and fill in info in shipping screen
        if (sdkRequest.shopperConfiguration.withShipping){
            gotoShippingScreen(fillInDetails: false)
            fillShippingDetails(shippingDetails: getDummyShippingDetails())
            shippingHelper.pressPayButton()
        }

        else{
            paymentHelper.pressPayButton()
        }
    }

    /* -------------------------------- Choose Payment Method views tests ---------------------------------------- */

    func testChooseExistingCardVisibility(){
        chooseNewCardPaymentMethodFlow(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)

    }



}