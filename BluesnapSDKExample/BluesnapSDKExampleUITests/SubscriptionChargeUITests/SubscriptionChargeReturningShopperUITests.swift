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
    
    /* -------------------------------- Subscription common tests ---------------------------------------- */
    
    func subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: Bool, shopperWithEmail: Bool, shopperWithShipping: Bool, checkoutFullBilling: Bool, checkoutWithEmail: Bool, checkoutWithShipping: Bool, trialPeriodDays: Int? = nil){
        
        setUpForSdkWithReturningShopper(shopperWithFullBilling: checkoutFullBilling, shopperWithEmail: shopperWithEmail, shopperWithShipping: shopperWithShipping, checkoutFullBilling: checkoutFullBilling, checkoutWithEmail: checkoutWithEmail, checkoutWithShipping: checkoutWithShipping, isSubscription: true, trialPeriodDays: trialPeriodDays)

        // check cc line visibility in existing cc screen
        existingCcHelper.checkExistingCCLineVisibility(expectedLastFourDigits: BSUITestUtils.getValidVisaLast4Digits(), expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
        
        // check all components visibility in existing cc screen
        existingCcHelper.checkScreenItems(sdkRequest: sdkRequest)
        
        // check pay button content
        existingCcHelper.checkPayButton(sdkRequest: sdkRequest, subscriptionHasPriceDetails: trialPeriodDays == nil)
    }
    
    /* -------------------------------- Subscription views tests ---------------------------------------- */
    
    func testViewsNoFullBillingNoShippingNoEmail_shopperWithFullBillingWithEmailWithShipping_withoutPriceDetails() {
        subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false, trialPeriodDays: 30)
    }

    func testViewsNoFullBillingNoShippingNoEmail_shopperWithFullBillingWithEmailWithShipping_withPriceDetails() {
        subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: false, checkoutWithEmail: false, checkoutWithShipping: false)
    }

    func testViewsFullBillingWithShippingWithEmail_shopperWithFullBillingWithEmailWithShipping_withoutPriceDetails() {
        subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true, trialPeriodDays: 28)
    }

    func testViewsFullBillingWithShippingWithEmail_shopperWithFullBillingWithEmailWithShipping_withPriceDetails() {
        subscriptionReturningShopperViewsCommomTester(shopperWithFullBilling: true, shopperWithEmail: true, shopperWithShipping: true, checkoutFullBilling: true, checkoutWithEmail: true, checkoutWithShipping: true)
    }
    
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

