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
//@testable import BluesnapSDKIntegrationTests //TODO: make it work

class SubscriptionChargeUITests: CheckoutBaseTester {
    
    func testViewsFullBillingWithShippingWithEmail() {
        setUpForCheckoutSdk(fullBilling: true, withShipping: true, withEmail: true, isSubscription: true)
        
        // check cc line visibility (including error messages)
        paymentHelper.checkNewCCLineVisibility()
        
        // check Inputs Fields visibility (including error messages)
        paymentHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.billingDetails)
        
        // check Store Card view visibility
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true)
        
        // check pay button when shipping same as billing is on
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)
        
        setShippingSameAsBillingSwitch(shouldBeOn: false)
        
        // check pay button when shipping same as billing is off
        paymentHelper.checkPayButton(sdkRequest: sdkRequest, shippingSameAsBilling: isShippingSameAsBillingOn)
        
        // check that the Store Card is mandatory
        paymentHelper.checkStoreCardVisibility(shouldBeVisible: true, isValid: false)
        
        // continue to shipping screen
        setStoreCardSwitch(shouldBeOn: true)
        gotoShippingScreen()
        
        // check Inputs Fields visibility (including error messages)
        shippingHelper.checkInputsVisibility(sdkRequest: sdkRequest, shopperDetails: sdkRequest.shopperConfiguration.shippingDetails)
        
        // check shipping pay button
        shippingHelper.checkPayButton(sdkRequest: sdkRequest)
        
        // fill in shipping details with country without shipping tax
        fillShippingDetails(shippingDetails: getDummyShippingDetails(countryCode: "IL"))
    }
}
