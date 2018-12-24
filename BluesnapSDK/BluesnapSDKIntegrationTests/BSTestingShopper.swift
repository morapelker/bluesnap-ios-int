//
//  BSTestingShopper.swift
//  BluesnapSDKIntegrationTests
//
//  Created by Sivani on 23/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import Foundation

class MockShopper{
    var email: String?
    var creditCardInfo: [String: TestingShopperCreditCardInfo] = [:]
    var shippingContactInfo: [String:String]? = nil
    var shopperCheckoutRequirements: TestingShopperCheckoutRequirements
    
    init(creditCardInfo: [([String:String],[String:String])], email: String? = nil, shippingContactInfo: [String:String]? = nil, fullBillingRequired: Bool, emailRequired: Bool, shippingRequired: Bool){

        for item in creditCardInfo{
            self.creditCardInfo[item.1["cardLastFourDigits"]!] = TestingShopperCreditCardInfo(billingContactInfo: item.0, creditCard: item.1)
        }
        
        self.shippingContactInfo = shippingContactInfo
        self.email = email

        shopperCheckoutRequirements = TestingShopperCheckoutRequirements(fullBillingRequired: fullBillingRequired, emailRequired: emailRequired, shippingRequired: shippingRequired)
    }
    
}

class TestingShopperCreditCardInfo{
    var billingContactInfo: [String:String] = [:]
    var creditCard: [String:String] = [:]
    
    init(billingContactInfo: [String:String], creditCard: [String:String]){
        self.billingContactInfo = billingContactInfo
        self.creditCard = creditCard
    }

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
