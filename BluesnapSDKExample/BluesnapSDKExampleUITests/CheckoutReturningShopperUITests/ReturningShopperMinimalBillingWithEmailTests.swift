//
//  ReturningShopperMinimalBillingWithEmailTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperMinimalBillingWithEmailTests: CheckoutReturningShopperUITests {
    
    /* -------------------------------- Returning shopper Minimal Billing With Email views tests ---------------------------------------- */
    
    func returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: false, checkoutWithEmail: true, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_1() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_2() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_3() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_4() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_5() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_6() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_7() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmail_8() {
        returningShopperViewsMinimalBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: true)

    }
    
}
