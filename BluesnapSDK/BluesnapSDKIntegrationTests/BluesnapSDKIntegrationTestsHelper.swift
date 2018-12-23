//
//  BluesnapSDKIntegrationTestsHelper.swift
//  BluesnapSDKIntegrationTests
//
//  Created by Sivani on 11/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
@testable import BluesnapSDK

class BluesnapSDKIntegrationTestsHelper {
    
    static func parseRetrieveVaultedShopperResponse(responseBody: Data?, fullBillingRequired: Bool, emailRequired: Bool, shippingRequired: Bool)->([String:String], [String:String], [String:String], BSErrors?){
        var billingData: [String:String] = [:]
        var ccData: [String:String] = [:]
        var shippingData: [String:String] = [:]

        var resultError: BSErrors? = nil
        if let data = responseBody {
            if !data.isEmpty {
                do {
                    // Parse the result JSOn object
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                        if emailRequired {
                            billingData["email"] = json["email"] as? String
                        }
                        
                        if let paymentSources = json["paymentSources"] as? [String: AnyObject] {
                            if let creditCardInfo = paymentSources["creditCardInfo"] as? [[String: Any]] {
                                for item in creditCardInfo{
                                    if let billingContactInfo = item["billingContactInfo"] as? [String: AnyObject] {
                                        billingData["firstName"] = billingContactInfo["firstName"] as? String
                                        billingData["lastName"] = billingContactInfo["lastName"] as? String
                                        billingData["country"] = billingContactInfo["country"] as? String
                                        billingData["state"] = billingContactInfo["state"] as? String
                                        billingData["address"] = billingContactInfo["address1"] as? String
                                        billingData["city"] = billingContactInfo["city"] as? String
                                        billingData["zip"] = billingContactInfo["zip"] as? String
                                    }
                                    if let creditCard = item["creditCard"] as? [String: AnyObject] {
                                        ccData["cardLastFourDigits"] = creditCard["cardLastFourDigits"] as? String
                                        ccData["cardType"] = creditCard["cardType"] as? String
                                        ccData["expirationMonth"] = creditCard["expirationMonth"] as? String
                                        ccData["expirationYear"] = creditCard["expirationYear"] as? String
                                    }
                                }
                            }
                        }
                        
                        if shippingRequired {
                            if let shippingContactInfo = json["shippingContactInfo"] as? [String: AnyObject] {
                                shippingData["firstName"] = shippingContactInfo["firstName"] as? String
                                shippingData["lastName"] = shippingContactInfo["lastName"] as? String
                                shippingData["country"] = shippingContactInfo["country"] as? String
                                shippingData["state"] = shippingContactInfo["state"] as? String
                                shippingData["address"] = shippingContactInfo["address1"] as? String
                                shippingData["city"] = shippingContactInfo["city"] as? String
                                shippingData["zip"] = shippingContactInfo["zip"] as? String
                            }
                        }
                        
                    } else {
                        NSLog("Error parsing BS result on Retrieve vaulted shopper")
                        resultError = .unknown
                    }
                } catch let error as NSError {
                    NSLog("Error parsing BS result on Retrieve vaulted shopper: \(error.localizedDescription)")
                    resultError = .unknown
                }
            }
        } else {
            NSLog("Error: no data exists")
            resultError = .unknown
            
        }
        return (ccData ,billingData, shippingData, resultError)
        
        
    }
    
    static func parseRetrieveVaultedShopperResponseNEW(responseBody: Data?, fullBillingRequired: Bool, emailRequired: Bool, shippingRequired: Bool)->([String: AnyObject], BSErrors?){
        var jsonData: [String: AnyObject] = [:]
        var resultError: BSErrors? = nil
        if let data = responseBody {
            if !data.isEmpty {
                do {
                    // Parse the result JSOn object
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                        jsonData = json
                        
                    } else {
                        NSLog("Error parsing BS result on Retrieve vaulted shopper")
                        resultError = .unknown
                    }
                } catch let error as NSError {
                    NSLog("Error parsing BS result on Retrieve vaulted shopper: \(error.localizedDescription)")
                    resultError = .unknown
                }
            }
        } else {
            NSLog("Error: no data exists")
            resultError = .unknown
            
        }
        return (jsonData, resultError)
        
    }
    
    
    private static func checkRetrieveVaultedShopperResponseNEW(jasonData: [String: AnyObject], expectedData: [String:String], resultData: [String:String]){
        for (fieldName, fieldValue) in resultData {
            checkFieldContent(expectedValue: expectedData[fieldName]!, actualValue: fieldValue, fieldName: fieldName)
        }
    }
    
    static func checkApiCallResult(expectedData: [String:String], resultData: [String:String]){
        for (fieldName, fieldValue) in resultData {
            checkFieldContent(expectedValue: expectedData[fieldName]!, actualValue: fieldValue, fieldName: fieldName)
        }
    }
    
    static func checkFieldContent(expectedValue: String, actualValue: String, fieldName: String){
        XCTAssertTrue(expectedValue == actualValue, "Field \(fieldName) was not saved correctly in DataBase")
    }
    
}
