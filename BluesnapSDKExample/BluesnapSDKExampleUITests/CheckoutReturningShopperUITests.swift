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
    
    func setUpForSdkWithReturningShopper(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithShipping: Bool, checkoutWithEmail: Bool){
        
        printShopperDiscription(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DemoAPIHelper.createVaultedShopper(fullBilling: shopperWithFullBilling, withEmail: shopperWithEmail, withShipping: shopperWithShipping, billingInfo: getDummyBillingDetails(), shippingInfo: getDummyShippingDetails(), creditCard: (Int(BSUITestUtils.getValidExpYear()) ?? 2026, Int(BSUITestUtils.getValidCvvNumber()) ?? 333, BSUITestUtils.getValidExpMonth(), BSUITestUtils.getValidVisaCreditCardNumberWithoutSpaces()), completion: { shopperId, error in
            if let shopperId_ = shopperId {
                self.vaultedShopperId = shopperId_
                semaphore.signal()
            }
        })
        
        semaphore.wait()
        
        setUpForSdk(fullBilling: checkoutFullBilling, withShipping: shopperWithShipping, withEmail: shopperWithEmail, isReturningShopper: true, shopperId: vaultedShopperId, tapExistingCc: true, checkExistingCcLine: true)
    
    }
    
    func printShopperDiscription(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool) {
        print("Shopper \(String(describing: vaultedShopperId)), with Full Billing: \(shopperWithFullBilling), with Email: \(shopperWithEmail), with Shipping: \(shopperWithShipping)")
        
    }
    
    /* -------------------------------- Returning shopper views tests ---------------------------------------- */
    
    func returningShopperViewsFullBillingNoShippingNoEmailCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool) {
        
        setUpForSdkWithReturningShopper(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithShipping: false, checkoutWithEmail: false)
        
//        paymentHelper.checkExistingCCLineVisibility(expectedLastFourDigits: BSUITestUtils.getValidVisaCCNLast4Digits(), expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
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
    
    
    
    
    
    
}
