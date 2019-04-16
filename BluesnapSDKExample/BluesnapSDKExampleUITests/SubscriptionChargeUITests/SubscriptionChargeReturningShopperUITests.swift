//
//  SubscriptionChargeReturningShopperUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 15/04/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import Foundation
import PassKit
import BluesnapSDK

class SubscriptionChargeReturningShopperUITests: CheckoutReturningShopperBaseTester {
    
    /* -------------------------------- Subscription views tests ---------------------------------------- */
    
    /* -------------------------------- Subscription end-to-end flow tests ---------------------------------------- */
    
    
    func testReturningShopperEndToEndMinimalBilling_shopperWithFullBillingWithEmailWithShipping() {
        setUpForSdkWithReturningShopper(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false)
        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: false)
    }
    
    func testReturningShopperEndToEndFullBillingWithEmailWithShipping_shopperWithFullBillingWithEmailWithShipping() {
        setUpForSdkWithReturningShopper(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true)
        
    }
}

