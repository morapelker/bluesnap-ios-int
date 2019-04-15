//
//  SubscriptionChargeUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 11/04/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import Foundation
import PassKit
import BluesnapSDK

class SubscriptionChargeNewShopperUITests: CheckoutBaseTester {
    
    /* -------------------------------- Subscription views tests ---------------------------------------- */

    func testViewsFullBillingWithShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: true, isSubscription: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check pay button when shipping same as billing is on
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn, isSubscription: true)
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn, isSubscription: true)
        
        // check that the Store Card is mandatory
        paymentHelper.checkStoreCardMandatory()
        
        // continue to shipping screen
        setStoreCardSwitch(shouldBeOn: true)
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest, isSubscription: true)
        
        // fill in shipping details with country without shipping tax
        fillShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "IL"))
    }
    
    /* -------------------------------- Subscription end-to-end flow tests ---------------------------------------- */
    
    func testFlowNoFullBillingNoShippingNoEmail() {
        newCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: false, storeCard: true, isSubscription: true)
    }
    
    func testFlowFullBillingWithShippingWithEmail() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true, storeCard: true, isSubscription: true)
    }
    
    func testFlowShippingSameAsBilling() {
        newCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true, shippingSameAsBilling: true, storeCard: true, isSubscription: true)
    }
    
    //TODO: fix this 2- add set up for returning shopper
//    func testReturningShopperEndToEndMinimalBilling_shopperWithFullBillingWithEmailWithShipping() {
//        existingCardBasicCheckoutFlow(fullBilling: false, withShipping: false, withEmail: false)
//    }
//
//    func testReturningShopperEndToEndFullBillingWithEmailWithShipping_shopperWithFullBillingWithEmailWithShipping() {
//        existingCardBasicCheckoutFlow(fullBilling: true, withShipping: true, withEmail: true)
//
//    }
}
