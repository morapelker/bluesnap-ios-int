//
//  BSUpdateShopperTests.swift
//  BluesnapSDK
//
//  Created by Roy Biber on 2018-12-25.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSUpdateShopperTests: XCTestCase {
    static var cc: [String: String] = [:]
    static var bsToken: BSToken = BSToken(tokenStr: "_")
    static var vaultedShopperId: Int = 0
    static var shopper: BSShopper = BSShopper()
    static var set2: Bool = true

    private var tokenExpiredExpectation: XCTestExpectation?
    private var tokenWasRecreated = false

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("----------------------------------------------------")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //------------------------------------------------------
    // MARK: Update Shopper
    //------------------------------------------------------

    func testUpdateShopperApplePay() {
        BSUpdateShopperTests.createShopper()
        BSUpdateShopperTests.updateShopperApplePay()
        BSUpdateShopperTests.checkSdkData()
    }

    func testUpdateShopperPayPal() {
        BSUpdateShopperTests.createShopper()
        BSUpdateShopperTests.updateShopperPayPal()
        BSUpdateShopperTests.checkSdkData()
    }

    func testUpdateCreditCard() {
        BSUpdateShopperTests.createShopper()
        BSUpdateShopperTests.updateShopperCreditCard()
        BSUpdateShopperTests.checkSdkData()
    }

    func testUpdateAll() {
        BSUpdateShopperTests.createShopper()
        BSUpdateShopperTests.updateShopperPayPal()
        BSUpdateShopperTests.checkSdkData()
        BSUpdateShopperTests.updateShopperCreditCard()
        BSUpdateShopperTests.checkSdkData()
        BSUpdateShopperTests.updateShopperApplePay()
        BSUpdateShopperTests.checkSdkData()
    }

    //------------------------------------------------------
    // MARK: private functions Shopper, Address & CC Creation
    //------------------------------------------------------

    static func createShopperForUpdate(add2: Bool, vaultedShopperId: Int, chosenPaymentMethodType: String, creditCard: BSCreditCard? = nil) -> BSShopper {
        let shopper = BSShopper()

        shopper.name = "John Doe" + (add2 ? "2" : "")
        shopper.country = "US"
        shopper.state = "AK"
        shopper.address = "some address" + (add2 ? "2" : "")
        shopper.address2 = "some address2" + (add2 ? "2" : "")
        shopper.city = "some city" + (add2 ? "2" : "")
        shopper.email = "some" + (add2 ? "2@email.com" : "@email.com")
        shopper.zip = "123456" + (add2 ? "2" : "")
        shopper.phone = "0541234567" + (add2 ? "2" : "")

        shopper.vaultedShopperId = vaultedShopperId

        shopper.chosenPaymentMethod = BSChosenPaymentMethod(chosenPaymentMethodType: chosenPaymentMethodType, creditCard: creditCard)

        return shopper
    }

    static func getShippingDetails(add2: Bool) -> BSShippingAddressDetails {
        let shippingDetails = BSShippingAddressDetails()
        shippingDetails.name = "Shipping John" + (add2 ? "2" : "")
        shippingDetails.country = "BR"
        shippingDetails.state = "AC"
        shippingDetails.address = "shipping address" + (add2 ? "2" : "")
        shippingDetails.city = "shipping city" + (add2 ? "2" : "")
        shippingDetails.zip = "123456" + (add2 ? "2" : "")
        return shippingDetails
    }

    static func getBillingDetails(add2: Bool) -> BSBillingAddressDetails {
        let billlingDetails = BSBillingAddressDetails()
        billlingDetails.name = "Billing John" + (add2 ? "2" : "")
        billlingDetails.country = "CA"
        billlingDetails.state = "ON"
        billlingDetails.address = "billing address" + (add2 ? "2" : "")
        billlingDetails.city = "billing city" + (add2 ? "2" : "")
        billlingDetails.zip = "123456" + (add2 ? "2" : "")
        billlingDetails.email = "billing" + (add2 ? "2@email.com" : "@email.com")
        return billlingDetails
    }

    static func getVisa() -> [String: String] {
        return ["ccn": "4111111111111111", "exp": "10/2020", "cvv": "111", "ccType": "VISA", "last4Digits": "1111", "issuingCountry": "US"]
    }

    static func getMasterCard() -> [String: String] {
        return ["ccn": "5555555555555557", "exp": "11/2021", "cvv": "123", "ccType": "MASTERCARD", "last4Digits": "5557", "issuingCountry": "BR"]
    }

    static func getBSCreditCard() -> BSCreditCard {
        let creditCard: BSCreditCard = BSCreditCard()
        creditCard.ccType = BSUpdateShopperTests.cc["ccType"]
        creditCard.last4Digits = BSUpdateShopperTests.cc["last4Digits"]
        let expArr = BSUpdateShopperTests.cc["exp"]?.components(separatedBy: "/")
        creditCard.expirationMonth = expArr![0]
        creditCard.expirationYear = expArr![1]
        return creditCard
    }

    //------------------------------------------------------
    // MARK: private functions API Calls
    //------------------------------------------------------

    static func createShopper() -> Int? {
        BSUpdateShopperTests.cc = getVisa()
        BSUpdateShopperTests.set2 = !BSUpdateShopperTests.set2

        let semaphore = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(completion: { token, error in
            BSUpdateShopperTests.bsToken = BSToken(tokenStr: token!.getTokenStr()!)
            NSLog("token: \(BSUpdateShopperTests.bsToken.tokenStr)")
            BSUpdateShopperTests.submitCCDetails(ccDetails: self.getVisa(), billingDetails: self.getBillingDetails(add2: BSUpdateShopperTests.set2), shippingDetails: self.getShippingDetails(add2: BSUpdateShopperTests.set2), completion: { error in
                semaphore.signal()
            })
        })
        semaphore.wait()

        let semaphore2 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createTokenizedTransaction(purchaseAmount: 10, purchaseCurrency: "USD", bsToken: BSUpdateShopperTests.bsToken, completion: { isSuccess, data, shopperId in
            assert(isSuccess == true, "true")
            if let shopperId = shopperId {
                BSUpdateShopperTests.vaultedShopperId = Int(shopperId)!
            } else {
                NSLog("Error: no data exists")
            }
            semaphore2.signal()
        })
        semaphore2.wait()
        return BSUpdateShopperTests.vaultedShopperId
    }

    private static func checkSdkData() {
        let semaphore4 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(shopperId: BSUpdateShopperTests.vaultedShopperId, completion: {
            token, error in

            if let error = error {
                fatalError("Create Token with shopper ID failed. error: \(error)")
            }
            BSUpdateShopperTests.getSdkData(shopper: BSUpdateShopperTests.shopper, completion: { error in
                semaphore4.signal()
            })

        })
        semaphore4.wait()
    }

    private static func updateShopperApplePay() {
        BSUpdateShopperTests.set2 = !BSUpdateShopperTests.set2

        let semaphore3 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(shopperId: BSUpdateShopperTests.vaultedShopperId, completion: {
            token, error in
            BSUpdateShopperTests.bsToken = BSToken(tokenStr: token!.getTokenStr()!)
            NSLog("token: \(BSUpdateShopperTests.bsToken.tokenStr)")
            BSUpdateShopperTests.shopper = self.createShopperForUpdate(add2: BSUpdateShopperTests.set2, vaultedShopperId: BSUpdateShopperTests.vaultedShopperId, chosenPaymentMethodType: BSPaymentType.ApplePay.rawValue)
            BSUpdateShopperTests.shopper.shippingDetails = self.getShippingDetails(add2: BSUpdateShopperTests.set2)
            BSApiManager.shopper = BSUpdateShopperTests.shopper
            BSApiManager.updateShopper(completion: {
                (result, error) in

                XCTAssert(error == nil, "error: \(String(describing: error))")
                semaphore3.signal()
            })
        })
        semaphore3.wait()
    }

    private static func updateShopperPayPal() {
        BSUpdateShopperTests.set2 = !BSUpdateShopperTests.set2

        let semaphore3 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(shopperId: BSUpdateShopperTests.vaultedShopperId, completion: {
            token, error in
            BSUpdateShopperTests.bsToken = BSToken(tokenStr: token!.getTokenStr()!)
            NSLog("token: \(BSUpdateShopperTests.bsToken.tokenStr)")
            BSUpdateShopperTests.shopper = self.createShopperForUpdate(add2: BSUpdateShopperTests.set2, vaultedShopperId: BSUpdateShopperTests.vaultedShopperId, chosenPaymentMethodType: BSPaymentType.PayPal.rawValue)
            BSUpdateShopperTests.shopper.shippingDetails = self.getShippingDetails(add2: BSUpdateShopperTests.set2)
            BSApiManager.shopper = BSUpdateShopperTests.shopper
            BSApiManager.updateShopper(completion: {
                (result, error) in

                XCTAssert(error == nil, "error: \(String(describing: error))")
                semaphore3.signal()
            })
        })
        semaphore3.wait()
    }

    private static func updateShopperCreditCard() {
        BSUpdateShopperTests.set2 = !BSUpdateShopperTests.set2

        let semaphore3 = DispatchSemaphore(value: 0)
        BSIntegrationTestingAPIHelper.createToken(shopperId: BSUpdateShopperTests.vaultedShopperId, completion: {
            token, error in
            BSUpdateShopperTests.bsToken = BSToken(tokenStr: token!.getTokenStr()!)
            NSLog("token: \(BSUpdateShopperTests.bsToken.tokenStr)")

            let semaphore4 = DispatchSemaphore(value: 1)
            BSUpdateShopperTests.cc = self.getMasterCard()
            BSUpdateShopperTests.submitCCDetails(ccDetails: BSUpdateShopperTests.cc, billingDetails: self.getBillingDetails(add2: BSUpdateShopperTests.set2), shippingDetails: self.getShippingDetails(add2: BSUpdateShopperTests.set2), completion: { error in
                semaphore4.signal()
            })
            semaphore4.wait()

            BSUpdateShopperTests.shopper = self.createShopperForUpdate(add2: BSUpdateShopperTests.set2, vaultedShopperId: BSUpdateShopperTests.vaultedShopperId,
                    chosenPaymentMethodType: BSPaymentType.CreditCard.rawValue, creditCard: self.getBSCreditCard())
            BSUpdateShopperTests.shopper.shippingDetails = self.getShippingDetails(add2: BSUpdateShopperTests.set2)
            BSApiManager.shopper = BSUpdateShopperTests.shopper
            BSApiManager.updateShopper(completion: {
                (result, error) in

                XCTAssert(error == nil, "error: \(String(describing: error))")
                semaphore3.signal()
            })
        })
        semaphore3.wait()
    }

    private static func getSdkData(shopper: BSShopper, completion: @escaping (BSErrors?) -> Void) {
        BSApiManager.getSdkData(baseCurrency: nil, completion: {
            sdkData, errors in

            XCTAssertNil(errors, "Got errors while trying to get currencies")
            XCTAssertNotNil(sdkData, "Failed to get sdk data")

            let sdkDataShopper = sdkData?.shopper
            XCTAssertNotNil(sdkDataShopper, "Failed to get shopper")
            XCTAssertEqual(shopper.chosenPaymentMethod?.chosenPaymentMethodType, sdkDataShopper?.chosenPaymentMethod?.chosenPaymentMethodType)
            NSLog("Result: getSdkData - chosenPaymentMethodType=\(sdkDataShopper?.chosenPaymentMethod?.chosenPaymentMethodType!)")
            if BSPaymentType.CreditCard.rawValue == shopper.chosenPaymentMethod?.chosenPaymentMethodType, let sdkDataCreditCard = sdkDataShopper?.chosenPaymentMethod?.creditCard, let creditCard = shopper.chosenPaymentMethod?.creditCard {
                XCTAssertEqual(creditCard.last4Digits, sdkDataCreditCard.last4Digits)
                XCTAssertEqual(creditCard.ccType, sdkDataCreditCard.ccType)
                NSLog("Result: getSdkData - ccType=\(creditCard.ccType!), last4Digits=\(creditCard.last4Digits!)")

                let shippingDetails = shopper.shippingDetails!
                XCTAssertEqual(shippingDetails.name, sdkDataShopper?.shippingDetails?.name)
                XCTAssertTrue((shippingDetails.country ?? "").caseInsensitiveCompare(sdkDataShopper?.shippingDetails?.country ?? "") == .orderedSame)
                XCTAssertTrue((shippingDetails.state ?? "").caseInsensitiveCompare(sdkDataShopper?.shippingDetails?.state ?? "") == .orderedSame)
                XCTAssertEqual(shippingDetails.address, sdkDataShopper?.shippingDetails?.address)
                XCTAssertEqual(shippingDetails.city, sdkDataShopper?.shippingDetails?.city)
                XCTAssertEqual(shippingDetails.zip, sdkDataShopper?.shippingDetails?.zip)

                NSLog("Result: getSdkDataShippingDetails - name=\(shippingDetails.name!), country=\(shippingDetails.country!), state=\(shippingDetails.state!), address=\(shippingDetails.address!), city=\(shippingDetails.city!), zip=\(shippingDetails.zip!)")

            }
            XCTAssertEqual(shopper.name, sdkDataShopper?.name)
            XCTAssertTrue((shopper.country ?? "").caseInsensitiveCompare(sdkDataShopper?.country ?? "") == .orderedSame)
            XCTAssertTrue((shopper.state ?? "").caseInsensitiveCompare(sdkDataShopper?.state ?? "") == .orderedSame)
            XCTAssertEqual(shopper.address, sdkDataShopper?.address)
            XCTAssertEqual(shopper.address2, sdkDataShopper?.address2)
            XCTAssertEqual(shopper.city, sdkDataShopper?.city)
            XCTAssertEqual(shopper.email, sdkDataShopper?.email)
            XCTAssertEqual(shopper.zip, sdkDataShopper?.zip)
            XCTAssertEqual(shopper.phone, sdkDataShopper?.phone)

            NSLog("Result: getSdkData - name=\(shopper.name!), country=\(shopper.country!), state=\(shopper.state!), address=\(shopper.address!), city=\(shopper.city!), email=\(shopper.email!), zip=\(shopper.zip!), phone=\(shopper.phone!)")

            completion(errors)
        })
    }

    private static func submitCCDetails(ccDetails: [String: String], billingDetails: BSBillingAddressDetails?, shippingDetails: BSShippingAddressDetails?, completion: @escaping (BSErrors?) -> Void) {
        BSApiManager.submitPurchaseDetails(ccNumber: ccDetails["ccn"], expDate: ccDetails["exp"], cvv: ccDetails["cvv"],
                last4Digits: nil, cardType: nil, billingDetails: billingDetails ?? nil, shippingDetails: shippingDetails ?? nil, fraudSessionId: nil, completion: {
            (result, error) in

            XCTAssert(error == nil, "error: \(error)")
            let ccType = result.ccType
            let last4 = result.last4Digits
            let country = result.ccIssuingCountry
            NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
            assert(last4 == ccDetails["last4Digits"], "last4 should be \(ccDetails["last4Digits"])")
            assert(ccType == ccDetails["ccType"], "CC Type should be \(ccDetails["ccType"])")
            assert(country == ccDetails["issuingCountry"], "country should be \(ccDetails["issuingCountry"])")
            completion(error)
        })

    }
}
