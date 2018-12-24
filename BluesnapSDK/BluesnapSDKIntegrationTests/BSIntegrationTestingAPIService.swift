//
//  BSIntegrationTestingAPIService.swift
//  BluesnapSDKIntegrationTests
//
//  Created by Sivani on 23/12/2018.
//  Copyright © 2018 Bluesnap. All rights reserved.
//

import Foundation
import XCTest

@testable import BluesnapSDK

class BSIntegrationTestingAPIService {
    
    static func createToken(shopperId: Int?, completion: @escaping (BSToken?, BSErrors?) -> Void) {
        createSandboxBSToken(shopperId: shopperId, completion: { bsToken, bsError in
            
            BSApiManager.setBsToken(bsToken: bsToken)
            XCTAssertNil(bsError)
            XCTAssertNotNil(bsToken)
            completion(bsToken, bsError)
        })
    }
    
    static func createToken(completion: @escaping (BSToken?, BSErrors?) -> Void) {
        createToken(shopperId: nil, completion: completion)
    }
    
    /**
     Get BlueSnap Token from BlueSnap server
     Normally you will not do this from the app.
     
     - parameters:
     - user: username
     - password: password
     - completion: callback function for after the token is created; recfeives optional token and optional error
     */
    static func createSandboxBSToken(shopperId: Int?, completion: @escaping (BSToken?, BSErrors?) -> Void) {
        
        let domain: String = BSApiManager.BS_SANDBOX_DOMAIN
        
        // create request
        var urlStr = domain + "services/2/payment-fields-tokens"
        if let shopperId = shopperId {
            urlStr = urlStr + "?shopperId=\(shopperId)"
        }
        let url = NSURL(string: urlStr)!
        var request = getURLRequest(urlStr: urlStr, httpMethod: "POST", contentType: "text/xml")
        
        // fire request
        
        var result: BSToken?
        var resultError: BSErrors?
        NSLog("BlueSnap; createSandboxBSToken")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            NSLog("BlueSnap; createSandboxBSToken completion")
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting BSToken - \(errorType). Error: \(error.localizedDescription)")
                resultError = .unknown
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode: Int = (httpResponse?.statusCode) {
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result = extractTokenFromResponse(httpResponse: httpResponse)
                        if let result = result {
                            NSLog("createSandboxBSToken result")
                        } else {
                            resultError = .unknown
                        }
                    } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
                        NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
                        resultError = .invalidInput
                    } else {
                        resultError = .unknown
                        NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
                    }
                } else {
                    resultError = .unknown
                    NSLog("Http error getting response for BSToken")
                }
            }
            defer {
                completion(result, resultError)
            }
        }
        task.resume()
    }
    
    
    private static func extractTokenFromResponse(httpResponse: HTTPURLResponse?) -> BSToken? {
        
        var result: BSToken?
        if let location: String = httpResponse?.allHeaderFields["Location"] as? String {
            if let lastIndexOfSlash = location.range(of: "/", options: String.CompareOptions.backwards, range: nil, locale: nil) {
                let tokenStr = String(location[lastIndexOfSlash.upperBound..<location.endIndex])
                result = BSToken(tokenStr: tokenStr)
            } else {
                NSLog("Error: BS Token does not contain /")
            }
        } else {
            NSLog("Error: BS Token does not appear in response headers")
        }
        return result
    }
    
    static func createTokenizedTransaction(
        purchaseAmount: Double,
        purchaseCurrency: String,
        bsToken: BSToken!,
        completion: @escaping (_ isSuccess: Bool, _ data: Data?, _ shopperId: String?)->Void) {
        
        var requestBody = [
            "amount": "\(purchaseAmount)",
            "recurringTransaction": "ECOMMERCE",
            "softDescriptor": "MobileSDKtest",
            "currency": "\(purchaseCurrency)",
            "cardTransactionType": "AUTH_CAPTURE",
            "pfToken": "\(bsToken.getTokenStr()!)",
            ] as [String : Any]
        print("requestBody= \(requestBody)")
        
        let authorization = getBasicAuth()
        
        let urlStr = bsToken.getServerUrl() + "services/2/transactions";
        let url = NSURL(string: urlStr)!
        
        var request = getURLRequest(urlStr: urlStr, httpMethod: "POST", contentType: "application/json", requestBody: requestBody)
        
        // fire request
        
        var result : (isSuccess:Bool, data: Data?, shopperId: String?) = (isSuccess:false, data: nil, shopperId: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error calling create transaction: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        result.data = data
                        NSLog("Response body = \(result.data!)")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.isSuccess = true
                        do {
                            if let json = try JSONSerialization.jsonObject(with: result.data!, options: .allowFragments) as? [String: AnyObject] {
                                result.shopperId = String(json["vaultedShopperId"] as! Int)
                            }
                        } catch let error as NSError {
                            NSLog("Error parsing BS result on Retrieve vaulted shopper: \(error.localizedDescription)")
                            result.isSuccess = false
                        }
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                completion(result.isSuccess, result.data, result.shopperId)
                
            }
        }
        task.resume()
    }
    
    static func retrieveVaultedShopper(
        vaultedShopperId shopperId: String,
        completion: @escaping (_ isSuccess: Bool, _ data: Data?)->Void) {
        
        print("shopperId= \(shopperId)")
        let authorization = getBasicAuth()
        
        let urlStr = BSApiManager.BS_SANDBOX_DOMAIN + "services/2/vaulted-shoppers/" + shopperId;
        let url = NSURL(string: urlStr)!
        
        var request = getURLRequest(urlStr: urlStr, httpMethod: "GET", contentType: "application/json")
        
        // fire request
        
        var result : (isSuccess:Bool, data: Data?) = (isSuccess:false, data: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error in calling retrieve vaulted shopper: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        result.data = data
                        let StringData = String(data: data, encoding: .utf8)
                        NSLog("Response body = \(StringData ?? "")")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.isSuccess = true
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                completion(result.isSuccess, result.data)
                
            }
        }
        task.resume()
    }
    
    /**
     Build the basic authentication header from username/password
     - parameters:
     - user: username
     - password: password
     */
    private static func getBasicAuth(user: String!, password: String!) -> String {
        let loginStr = String(format: "%@:%@", user, password)
        let loginData = loginStr.data(using: String.Encoding.utf8)!
        let base64LoginStr = loginData.base64EncodedString()
        return "Basic \(base64LoginStr)"
    }
    
    /**
     Build the basic authentication header from username/password
     */
    private static func getBasicAuth() -> String {
        return getBasicAuth(user: BSApiManager.BS_SANDBOX_TEST_USER, password: BSApiManager.BS_SANDBOX_TEST_PASSWORD)
    }
    
    /**
     Build a basic URL Request
     - parameters:
     - urlStr: url
     - httpMethod: operationt type to request
     - ContentType: content type of the request
     */
    private static func getURLRequest(urlStr: String, httpMethod: String, contentType: String, requestBody: Any? = nil) -> NSMutableURLRequest {
        let authorization = getBasicAuth()
        let url = NSURL(string: urlStr)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = httpMethod
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        //request.setValue("0", forHTTPHeaderField: "Content-Length")
        request.setValue(BSApiCaller.BLUESNAP_VERSION_HEADER_VAL, forHTTPHeaderField: BSApiCaller.BLUESNAP_VERSION_HEADER)
        request.setValue(BSApiCaller.SDK_VERSION_HEADER_VAL, forHTTPHeaderField: BSApiCaller.SDK_VERSION_HEADER)
        if let requestBody = requestBody {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            } catch let error {
                NSLog("Error serializing request body: \(error.localizedDescription)")
            }
        }
        return request

    }
}
