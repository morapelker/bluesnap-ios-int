//
//  CheckoutBaseTester.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 06/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

//import Foundation
//import XCTest
//import PassKit
//import BluesnapSDK
//@testable import BluesnapSDKIntegrationTests //TODO: make it work

class CheckoutBaseTester: UIBaseTester{
//    internal var isReturningShopper: Bool = false
    
    internal func setUpForCheckoutSdk(fullBilling: Bool, withShipping: Bool, withEmail: Bool, allowCurrencyChange: Bool = true, hideStoreCardSwitch: Bool = false, isReturningShopper: Bool = false, shopperId: String? = nil, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false, isSubscription: Bool = false){

        super.setUpForSdk(fullBilling: fullBilling, withShipping: withShipping, withEmail: withEmail, allowCurrencyChange: allowCurrencyChange, hideStoreCardSwitch: hideStoreCardSwitch, isReturningShopper: isReturningShopper, shopperId: shopperId)
        
        // start checkout
        gotoPaymentScreen(shopperId: shopperId, tapExistingCc: tapExistingCc, checkExistingCcLine: checkExistingCcLine, isSubscription: isSubscription)
    }
    
    private func gotoPaymentScreen(shopperId: String? = nil, tapExistingCc: Bool = false, checkExistingCcLine: Bool = false, isSubscription: Bool = false){
        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)
        
        // click "Checkout" button / "Subscription" button
        if(isSubscription){
            app.buttons["SubscriptionButton"].tap()

        } else {
            app.buttons["CheckoutButton"].tap()
        }
        
        // wait for payment type screen to load
        let ccButton = paymentTypeHelper.getCcButtonElement()
        waitForElementToExist(element: ccButton, waitTime: 120)
        
        // make sure payment type buttons are visible
        paymentTypeHelper.checkPaymentTypes(expectedApplePay: true, expectedPayPal: true, expectedCC: true)
        
        if tapExistingCc {
            if (checkExistingCcLine) {// check existing CC line
                paymentTypeHelper.checkExistingCCLine(index: 0, expectedLastFourDigits: "1111", expectedExpDate: "\(BSUITestUtils.getValidExpMonth()) / \(BSUITestUtils.getValidExpYear())")
            }
            
            // click existing CC
            app.buttons["existingCc0"].tap()
            
        } else {
            // click New CC button
            app.buttons["CcButton"].tap()
        }
    }
    
}

