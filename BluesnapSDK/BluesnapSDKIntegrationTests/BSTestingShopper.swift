//
//  BSTestingShopper.swift
//  BluesnapSDKIntegrationTests
//
//  Created by Sivani on 23/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import Foundation

class TestingShopper{
    var billingContactInfo: [String:String] = [:]
    var shippingContactInfo: [String:String]? = nil
    var creditCardInfo: [([String:String],[String:String])] = []
    var shopperCheckoutRequirements: TestingShopperCheckoutRequirements
    
    init(billingContactInfo: [String:String], shippingContactInfo: [String:String]? = nil, creditCardInfo: [([String:String],[String:String])], fullBillingRequired: Bool, emailRequired: Bool, shippingRequired: Bool){
        self.billingContactInfo = billingContactInfo
        self.creditCardInfo = creditCardInfo
        self.shippingContactInfo = shippingContactInfo
        
        shopperCheckoutRequirements = TestingShopperCheckoutRequirements(fullBillingRequired: fullBillingRequired, emailRequired: emailRequired, shippingRequired: shippingRequired)
    }
    
}

class TestingShopperCreditCardInfo{
    
}

class TestingShopperCheckoutRequirements{
    var fullBillingRequired: Bool
    var emailRequired: Bool
    var shippingRequired: Bool

    
    init(fullBillingRequired: Bool, emailRequired: Bool, shippingRequired: Bool){
        self.fullBillingRequired = fullBillingRequired
        self.emailRequired = emailRequired
        self.shippingRequired = shippingRequired

        
    }
}
