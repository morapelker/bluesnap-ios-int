//
//  ReturningShopperFullBillingWithShippingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperFullBillingWithShippingTests: CheckoutReturningShopperUITests {
    
    /* -------------------------------- Returning shopper Full Billing With Shipping views tests ---------------------------------------- */
    
    func returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_1() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_2() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_3() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_4() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_5() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_6() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_7() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBillingWithShipping_8() {
        returningShopperViewsFullBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: false)

    }
    
}
