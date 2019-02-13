//
//  ReturningShopperFullBillingWithEmailWithShippingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperFullBillingWithEmailWithShippingTests: CheckoutReturningShopperUITests {
    
    /* -------------------------------- Returning shopper Full Billing With Email With Shipping views tests ---------------------------------------- */
    
    func returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_1() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_2() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_3() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_4() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_5() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_6() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_7() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithEmailWithShipping_8() {
        returningShopperViewsFullBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true)

    }
    
}
