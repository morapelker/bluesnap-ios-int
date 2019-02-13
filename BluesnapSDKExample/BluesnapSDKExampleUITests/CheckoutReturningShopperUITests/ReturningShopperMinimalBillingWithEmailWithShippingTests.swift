//
//  ReturningShopperMinimalBillingWithEmailWithShippingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperMinimalBillingWithEmailWithShippingTests: CheckoutReturningShopperUITests {
    
    /* -------------------------------- Returning shopper Full Billing With Email With Shipping views tests ---------------------------------------- */
    
    func returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: false, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_1() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_2() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_3() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_4() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_5() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_6() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_7() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsMinimalBillingWithEmailWithShipping_8() {
        returningShopperViewsMinimalBillingWithEmailWithShippingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: true, withEmail: true)

    }
    
}
