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
    
    func returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool) {
        
        // set-up for sdk and start returning shopper checkout (with cc line validation in payment type screen)
        setUpForSdkWithReturningShopper(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
        
        // check cc line visibility in existing cc screen
        existingCcHelper.checkExistingCCLineVisibility(expectedLastFourDigits: BSUITestUtils.getValidVisaCCNLast4Digits(), expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
        
        existingCcHelper.checkScreenItems(sdkRequest: sdkRequest)
        
        // check billing info visibility in existing cc screen
        existingCcHelper.checkNameLabelContent(sdkRequest: sdkRequest, isBilling: true)
        
        let (fullBillingDisplay, emailDisplay, shippingDisplay) = getDisplayConfiguration(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)
        
        existingCcHelper.checkAddressBoxContent(sdkRequest: sdkRequest, isBilling: true, fullBillingDisplay: fullBillingDisplay, emailDisplay: emailDisplay, shippingDisplay: shippingDisplay)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_1() {
        returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_2() {
        returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_3() {
        returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_4() {
        returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_5() {
        returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_6() {
        returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_7() {
        returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingNoShippingNoEmail_8() {
        returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func getDisplayConfiguration(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool) -> (Bool, Bool, Bool) {
        
        let fullBillingDisplay = sdkRequest.shopperConfiguration.fullBilling && shopperWithFullBilling
        let emailDisplay = sdkRequest.shopperConfiguration.withEmail && shopperWithEmail
        let shippingDisplay = sdkRequest.shopperConfiguration.withShipping && shopperWithShipping
        
        return (fullBillingDisplay, emailDisplay, shippingDisplay)
    }
    
    
    
    
}
