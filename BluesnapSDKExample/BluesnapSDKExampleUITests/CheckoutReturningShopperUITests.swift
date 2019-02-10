//
//  CheckoutReturningShopperUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 06/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class CheckoutReturningShopperUITests: CheckoutBaseTester {
    private var existingCcHelper: BSExistingCcScreenUITestHelper!
    private var vaultedShopperId: String!

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        //        app.terminate()
        
    }
    
    func setUpForSdkWithReturningShopper(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool){
        
        // initialize required helpers
        existingCcHelper = BSExistingCcScreenUITestHelper(app: app)
        
        printShopperDiscription(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DemoAPIHelper.createVaultedShopper(fullBilling: shopperWithFullBilling, withEmail: shopperWithEmail, withShipping: shopperWithShipping, billingInfo: getDummyBillingDetails(), shippingInfo: getDummyShippingDetails(), creditCard: (Int(BSUITestUtils.getValidExpYear()) ?? 2026, Int(BSUITestUtils.getValidCvvNumber()) ?? 333, BSUITestUtils.getValidExpMonth(), BSUITestUtils.getValidVisaCreditCardNumberWithoutSpaces()), completion: { shopperId, error in
            if let shopperId_ = shopperId {
                self.vaultedShopperId = shopperId_
                semaphore.signal()
            }
        })
        
        semaphore.wait()
        
        setUpForSdk(fullBilling: checkoutFullBilling, withShipping: checkoutWithShipping, withEmail: checkoutWithEmail, isReturningShopper: true, shopperId: vaultedShopperId, tapExistingCc: true, checkExistingCcLine: true)
        
        setShopperDetailsInSdkRequest(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)
        
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
    
    }
    
    func printShopperDiscription(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool) {
        print("Shopper \(String(describing: vaultedShopperId)), with Full Billing: \(shopperWithFullBilling), with Email: \(shopperWithEmail), with Shipping: \(shopperWithShipping)")
        
    }
    
    /* -------------------------------- Returning shopper views tests ---------------------------------------- */
    
    func returningShopperViewsCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool) {
        
        // set-up for sdk and start returning shopper checkout (with cc line validation in payment type screen)
        setUpForSdkWithReturningShopper(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping)
        
        // check cc line visibility in existing cc screen
        existingCcHelper.checkExistingCCLineVisibility(expectedLastFourDigits: BSUITestUtils.getValidVisaCCNLast4Digits(), expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
        
        // check all components visibility in existing cc screen
        existingCcHelper.checkScreenItems(sdkRequest: sdkRequest)
        
        // check summarized billing info visibility in existing cc screen
        existingCcHelper.checkNameLabelContent(sdkRequest: sdkRequest, isBilling: true)
        
        let (fullBillingDisplay, emailDisplay, shippingDisplay) = getDisplayConfiguration(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)
        
        existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: true, fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, shippingDisplay: shippingDisplay)
        
        // innef views tests: only for one option
        if (shopperWithFullBilling == sdkRequest.shopperConfiguration.fullBilling &&
            shopperWithEmail == sdkRequest.shopperConfiguration.withEmail &&
            shopperWithShipping == sdkRequest.shopperConfiguration.withShipping){
            
            existingCardTestPaymentAndShippingScreens(fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, shippingDisplay: shippingDisplay)
            
        }
        
        else{
            checkComponentOpensIfMissingInfo(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)
        }
    }
    
    func existingCardTestPaymentAndShippingScreens(fullBillingDisplay: Bool, emailDisplay: Bool, shippingDisplay: Bool){
        // check pay button content
        existingCcHelper.checkPayButton(sdkRequest: sdkRequest)
        
        // check that the billing info inputs presents the correct content (when pressing edit)
        existingCcHelper.editBillingButton.tap()
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        
        //go back to ExistingCC screen
        BSUITestUtils.pressBackButton(app: app)
        
        // check that the summarized billing info presents the old content after editing but not pressing "Done" button (but "back")
        editBillingDetailsValidation(fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, useDoneButton: false)
        
        // check that the summarized billing info presents the new content after editing and pressing "Done" button (not "back")
        editBillingDetailsValidation(fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, useDoneButton: true)
    }
    
    /*
     This test verifies that the summarized billing contact info and the
     billing contact info presents the correct content after editing the info,
     If useDoneButton is true then it uses "Done" button and verifies the info changes,
     o.w. it uses the "Back" button and verifies the info doesn't change.
     Pre-condition: current screen is ExistingCC
     */
    func editBillingDetailsValidation(fullBillingDisplay: Bool, emailDisplay: Bool, useDoneButton: Bool){
        existingCcHelper.editBillingButton.tap()
        
        if (useDoneButton){
            setBillingDetails(billingDetails: BSUITestUtils.getDummyEditBillingDetails())
            paymentHelper.pressPayButton()
            existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: true, fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, shippingDisplay: false)
        }
        
        else {
            // fill in billing info without saving in sdkRequest
            paymentHelper.setFieldValues(billingDetails: BSUITestUtils.getDummyEditBillingDetails(), sdkRequest: sdkRequest)
            BSUITestUtils.pressBackButton(app: app)
            existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: true, fullBillingDisplay: sdkRequest.shopperConfiguration.fullBilling, emailDisplay: sdkRequest.shopperConfiguration.withEmail, shippingDisplay: sdkRequest.shopperConfiguration.withShipping)
        }
        
        existingCcHelper.editBillingButton.tap()
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails, zipLabel: "Billing Zip")
        BSUITestUtils.pressBackButton(app: app)
    }
    
    /*
     This test verifies that the summarized shipping contact info and the
     billing contact info presents the correct content after editing the info,
     If useDoneButton is true then it uses "Done" button and verifies the info changes,
     o.w. it uses the "Back" button and verifies the info doesn't change.
     Pre-condition: current screen is ExistingCC
     */
    func editShippingDetailsValidation(emailDisplay: Bool, shippingDisplay: Bool, useDoneButton: Bool){
        existingCcHelper.editShippingButton.tap()

        if (useDoneButton){
            setShippingDetails(shippingDetails: BSUITestUtils.getDummyEditShippingDetails())
            shippingHelper.pressPayButton()
            
            existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: false, fullBillingDisplay: false, emailDisplay: emailDisplay, shippingDisplay: shippingDisplay)
        }
            
        else {
            // fill in shipping info without saving in sdkRequest
            shippingHelper.setFieldValues(shippingDetails: BSUITestUtils.getDummyEditShippingDetails(), sdkRequest: sdkRequest)

            BSUITestUtils.pressBackButton(app: app)
            existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: false, fullBillingDisplay: sdkRequest.shopperConfiguration.fullBilling, emailDisplay: sdkRequest.shopperConfiguration.withEmail, shippingDisplay: sdkRequest.shopperConfiguration.withShipping)
        }
        
        existingCcHelper.editShippingButton.tap()
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails, zipLabel: "Shipping Zip")
        BSUITestUtils.pressBackButton(app: app)

    }
    
    /**
     This test verifies that when there is missing info in returning shopper,
     and we press "pay", it passes to the required edit component,
     and not making a transaction.
     Pre-condition: current screen is ExistingCC
     */
    func checkComponentOpensIfMissingInfo(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        
        var waitForScreenFunc: ()? = nil
        
        if ((sdkRequest.shopperConfiguration.fullBilling && !shopperWithFullBilling) || (sdkRequest.shopperConfiguration.withEmail && !shopperWithEmail)) {
            waitForScreenFunc = waitForPaymentScreen()
        }
        
        else if(sdkRequest.shopperConfiguration.withShipping && !shopperWithShipping){
            waitForScreenFunc = waitForShippingScreen()
        }
        
    
        if let waitForScreenFunc_ = waitForScreenFunc {
            existingCcHelper.pressPayButton()
            waitForScreenFunc_
        }
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_1() {
        returningShopperViewsCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_2() {
        returningShopperViewsCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_3() {
        returningShopperViewsCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_4() {
        returningShopperViewsCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_5() {
        returningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_6() {
        returningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_7() {
        returningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_8() {
        returningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    // Return expected display configuration for full billing, shipping and email
    func getDisplayConfiguration(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool) -> (Bool, Bool, Bool) {
        
        let fullBillingDisplay = sdkRequest.shopperConfiguration.fullBilling && shopperWithFullBilling
        let emailDisplay = sdkRequest.shopperConfiguration.withEmail && shopperWithEmail
        let shippingDisplay = sdkRequest.shopperConfiguration.withShipping && shopperWithShipping
        
        return (fullBillingDisplay, emailDisplay, shippingDisplay)
    }
    
    
    
    
}
