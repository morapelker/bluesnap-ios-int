//
//  BSUITestsUtils.swift
//  BluesnapSDKExampleUITests
//
//  Created by Sivani on 06/02/2019.
//  Copyright © 2019 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK

class BSUITestUtils {
    
    static func checkRetrieveVaultedShopperResponse(responseBody: Data, sdkRequest: BSSdkRequest, expectedCreditCardInfo: (String,String,String,String), shippingSameAsBilling: Bool = false) -> BSErrors? {
        var resultError: BSErrors? = nil
        do {
            // Parse the result JSOn object
            if let jsonData = try JSONSerialization.jsonObject(with: responseBody, options: .allowFragments) as? [String: AnyObject] {
                if sdkRequest.shopperConfiguration.withEmail {
                    checkFieldContent(expectedValue: (sdkRequest.shopperConfiguration.billingDetails?.email!)!, actualValue: jsonData["email"] as! String, fieldName: "email")
                }
                
                if let paymentSources = jsonData["paymentSources"] as? [String: AnyObject] {
                    if let creditCardInfo = paymentSources["creditCardInfo"] as? [[String: Any]] {
                        for item in creditCardInfo {
                            if let creditCard = item["creditCard"] as? [String: AnyObject], let billingContactInfo = item["billingContactInfo"] as? [String: AnyObject] {
                                //TODO: integrate this for multiple cc
//                                let cardLastFourDigits = creditCard["cardLastFourDigits"] as? String
                                checkShopperInfo(sdkRequest: sdkRequest, resultData: billingContactInfo, isBilling: true)
                                checkCreditCardInfo(expectedCreditCardInfo: expectedCreditCardInfo, resultData: creditCard)
                            }
                        }
                    }
                }
                
                if sdkRequest.shopperConfiguration.withShipping {
                    if let shippingContactInfo = jsonData["shippingContactInfo"] as? [String: AnyObject] {
                        checkShopperInfo(sdkRequest: sdkRequest, resultData: shippingContactInfo, isBilling: shippingSameAsBilling)
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
        
        return resultError
        
    }
    
    static func checkCreditCardInfo(expectedCreditCardInfo: (String,String,String,String), resultData: [String: AnyObject]) {
        checkFieldContent(expectedValue: expectedCreditCardInfo.0 , actualValue: resultData["cardLastFourDigits"] as! String, fieldName: "cardLastFourDigits")
        checkFieldContent(expectedValue: expectedCreditCardInfo.1, actualValue: resultData["cardType"] as! String, fieldName: "cardType")
        checkFieldContent(expectedValue: expectedCreditCardInfo.2, actualValue: resultData["expirationMonth"] as! String, fieldName: "expirationMonth")
        checkFieldContent(expectedValue: expectedCreditCardInfo.3, actualValue: resultData["expirationYear"] as! String, fieldName: "expirationYear")
    }
    
    static func checkShopperInfo(sdkRequest: BSSdkRequest, resultData: [String: AnyObject], isBilling: Bool) {
//        let address = "address1"
        let fullInfo = (isBilling && sdkRequest.shopperConfiguration.fullBilling) || !isBilling
        let shopperInfo = isBilling ? sdkRequest.shopperConfiguration.billingDetails! : sdkRequest.shopperConfiguration.shippingDetails!
        let country = shopperInfo.country!
        
        let (firstName, lastName) = shopperInfo.getSplitName()!
        checkFieldContent(expectedValue: firstName, actualValue: resultData["firstName"] as! String, fieldName: "firstName")
        checkFieldContent(expectedValue: lastName, actualValue: resultData["lastName"] as! String, fieldName: "lastName")
        checkFieldContent(expectedValue: country.lowercased(), actualValue: resultData["country"] as! String, fieldName: "country")
        
        if (checkCountryHasZip(country: country)){
            checkFieldContent(expectedValue: shopperInfo.zip!, actualValue: resultData["zip"] as! String, fieldName: "zip")
        }
        
        if (fullInfo){ //full billing or shipping
            if (checkCountryHasState(country: country)){
                checkFieldContent(expectedValue: shopperInfo.state!, actualValue: resultData["state"] as! String, fieldName: "state")
            }
            checkFieldContent(expectedValue: shopperInfo.city!, actualValue: resultData["city"] as! String, fieldName: "city")
            checkFieldContent(expectedValue: shopperInfo.address!, actualValue: resultData["address1"] as! String, fieldName: "address")
        }
        
    }
    
    static func checkFieldContent(expectedValue: String, actualValue: String, fieldName: String) {
        XCTAssertEqual(expectedValue, actualValue, "Field \(fieldName) was not saved correctly in DataBase")
    }
    
    static func checkCountryHasState(country: String) -> Bool {
        var countryHasState = false
        
        if country == "US" || country == "CA" || country == "BR" {
            countryHasState =  true
        }
        
        return countryHasState
    }
    
    static func checkCountryHasZip(country: String) -> Bool {
        let countryHasZip = !BSCountryManager.getInstance().countryHasNoZip(countryCode: country)
        return countryHasZip
    }
    
    static func getVisaCard() -> [String: String] {
        return ["ccn": "4111111111111111", "exp": "10/2020", "cvv": "111", "ccType": "VISA", "last4Digits": "1111", "issuingCountry": "US"]
    }
    
    static func getMasterCard() -> [String: String] {
        return ["ccn": "5555555555555557", "exp": "11/2021", "cvv": "123", "ccType": "MASTERCARD", "last4Digits": "5557", "issuingCountry": "BR"]
    }
    
    static func getDummyBillingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSBillingAddressDetails {
        
        let billingDetails = BSBillingAddressDetails(email: "shevie@gmail.com", name: "Shevie Chen", address: "58 somestreet", city : "somecity", zip : "4282300", country : countryCode, state : stateCode)
        return billingDetails
    }
    
    static func getDummyShippingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSShippingAddressDetails {
        
        let shippingDetails = BSShippingAddressDetails(name: "Funny Brice", address: "77 Rambla street", city : "Barcelona", zip : "4815", country : countryCode, state : stateCode)
        return shippingDetails
    }
    
    static func getDummyEditBillingDetails(countryCode: String? = "US", stateCode: String? = "NY") -> BSBillingAddressDetails {
        
        let billingDetails = BSBillingAddressDetails(email: "test@sdk.com", name: "La Fleur", address: "555 Broadway street", city : "New York", zip : "3abc 324a", country : countryCode, state : stateCode)
        return billingDetails
    }
    
    static func getDummyEditShippingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSShippingAddressDetails {
        
        let shippingDetails = BSShippingAddressDetails(name: "Janet Weiss", address: "75 some street", city : "Denton", zip : "162342", country : countryCode, state : stateCode)
        return shippingDetails
    }
    
    static func getValidVisaCreditCardNumber()->String {
        return "4111 1111 1111 1111"
    }
    
    static func getValidVisaCreditCardNumberWithoutSpaces()->String {
        return "4111111111111111"
    }
    
    static func getValidVisaCCNLast4Digits()->String {
        return "1111"
    }
    
    static func getValidExpDate()->String {
        return "1126"
    }
    
    static func getValidExpYear()->String {
        return "2026"
    }
    
    static func getValidExpMonth()->String {
        return "11"
    }
    
    static func getValidCvvNumber()->String {
        return "333"
    }
    
    static func getValidMCCreditCardNumber()->String {
        return "5572 7588 8601 5288"
    }
    
    
    static func getInvalidCreditCardNumber()->String {
        return "5572 7588 8112 2333"
    }
    
}

extension XCUIElement {
    func clearText() {
        tap()
        guard let stringValue = self.value as? String else {
            return
        }
        
        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        self.typeText(deleteString)
    }
}
