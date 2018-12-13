//
//  BSSdkRequestResultTests.swift
//  BluesnapSDK
//
//  Created by Roy Biber on 05/11/2018.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSSdkRequestResultTests: XCTestCase {

    override func setUp() {
        print("----------------------------------------------------")
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testType() {
        let sdkRequestShopperRequirements = BSSdkRequestShopperRequirements(withEmail: false,
                withShipping: false,
                fullBilling: false,
                billingDetails: nil,
                shippingDetails: nil,
                purchaseFunc: { _ in }
        )

        XCTAssertTrue(sdkRequestShopperRequirements is BSSdkRequestShopperRequirements)

        let sdkRequest = BSSdkRequest(withEmail: false,
                withShipping: false,
                fullBilling: false,
                priceDetails: BSPriceDetails(amount: 10, taxAmount: 10, currency: "USD"),
                billingDetails: nil,
                shippingDetails: nil,
                purchaseFunc: { _ in },
                updateTaxFunc: nil
        )

        XCTAssertTrue(sdkRequest is BSSdkRequest)

        let sdkResultShopperRequirements = BSBaseSdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertTrue(sdkResultShopperRequirements.isShopperRequirements())

        let sdkResultShopperRequirementsApplePay = BSApplePaySdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertTrue(sdkResultShopperRequirementsApplePay.getChosenPaymentMethodType() == BSPaymentType.ApplePay)

        let sdkResultShopperRequirementsPayPal = BSPayPalSdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertTrue(sdkResultShopperRequirementsPayPal.getChosenPaymentMethodType() == BSPaymentType.PayPal)

        let sdkResultShopperRequirementsCC = BSCcSdkResult(sdkRequestBase: sdkRequestShopperRequirements)
        XCTAssertTrue(sdkResultShopperRequirementsCC.getChosenPaymentMethodType() == BSPaymentType.CreditCard)

        let sdkResult = BSBaseSdkResult(sdkRequestBase: sdkRequest)
        XCTAssertTrue(!sdkResult.isShopperRequirements())

        let sdkResultApplePay = BSApplePaySdkResult(sdkRequestBase: sdkRequest)
        XCTAssertTrue(sdkResultApplePay.getChosenPaymentMethodType() == BSPaymentType.ApplePay)

        let sdkResultPayPal = BSPayPalSdkResult(sdkRequestBase: sdkRequest)
        XCTAssertTrue(sdkResultPayPal.getChosenPaymentMethodType() == BSPaymentType.PayPal)

        let sdkResultCC = BSCcSdkResult(sdkRequestBase: sdkRequest)
        XCTAssertTrue(sdkResultCC.getChosenPaymentMethodType() == BSPaymentType.CreditCard)

    }
}
