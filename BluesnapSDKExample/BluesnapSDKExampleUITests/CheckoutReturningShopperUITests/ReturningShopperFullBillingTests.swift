//
//  ReturningShopperFullBillingTests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation

class ReturningShopperFullBillingTests: CheckoutReturningShopperUITests {
    
    /* -------------------------------- Returning shopper Full Billing views tests ---------------------------------------- */
    
    func returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool){
        returningShopperViewsCommomTester(shopperWithFullBilling: shopperWithFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: true, checkoutWithEmail: false, checkoutWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_1() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_2() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_3() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBilling_4() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: false, shopperWithEmail: true, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBilling_5() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_6() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: false)
    }
    
    func testReturningShopperViewsFullBilling_7() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: false, shopperWithShipping: true)
    }
    
    func testReturningShopperViewsFullBilling_8() {
        returningShopperViewsFullBillingCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: false, withEmail: false)
    }
}
