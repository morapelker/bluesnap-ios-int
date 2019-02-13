//
//  ReturningShopperMinimalBillingWithShippingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperMinimalBillingWithShippingTests: CheckoutReturningShopperUITests {
    
    /* -------------------------------- Returning shopper Minimal Billing With Shipping views tests ---------------------------------------- */
    
    func returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_1() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_2() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_3() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_4() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_5() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_6() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_7() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithShipping_8() {
        returningShopperViewsMinimalBillingWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: true, withEmail: false)

    }
    
}
