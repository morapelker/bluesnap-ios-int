//
//  ReturningShopperFullBillingWithEmailTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperFullBillingWithEmailTests: CheckoutReturningShopperUITests {
    
    /* -------------------------------- Returning shopper Full Billing With Email views tests ---------------------------------------- */
    
    func returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_1() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_2() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_3() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_4() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_5() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_6() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_7() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmail_8() {
        returningShopperViewsFullBillingWithEmailCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: false, withEmail: true)
    }
    
}
