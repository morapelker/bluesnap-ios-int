//
//  BSShopperConfigurationTests.swift
//  BluesnapSDK
//
//  Created by Roy Biber on 05/11/2018.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSStoreCardTests: XCTestCase {

    override func setUp() {
        print("----------------------------------------------------")
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testStoreCardInSDKRequest() {
        // In BSSdkRequestShopperRequirements hiding the button should not be possible
        var sdkRequestShopperRequirements = BSSdkRequestShopperRequirements(withEmail: false,
                withShipping: false,
                fullBilling: false,
                billingDetails: nil,
                shippingDetails: nil,
                purchaseFunc: { _ in }
        )

        sdkRequestShopperRequirements.hideStoreCardSwitch = false
        XCTAssertTrue(!sdkRequestShopperRequirements.hideStoreCardSwitch)

        sdkRequestShopperRequirements.hideStoreCardSwitch = true
        XCTAssertTrue(!sdkRequestShopperRequirements.hideStoreCardSwitch)

        var sdkRequest = BSSdkRequest(withEmail: false,
                withShipping: false,
                fullBilling: false,
                priceDetails: BSPriceDetails(amount: 10, taxAmount: 10, currency: "USD"),
                billingDetails: nil,
                shippingDetails: nil,
                purchaseFunc: { _ in },
                updateTaxFunc: nil
        )

        XCTAssertFalse(sdkRequest.hideStoreCardSwitch)

        sdkRequest.hideStoreCardSwitch = true
        XCTAssertTrue(sdkRequest.hideStoreCardSwitch)

        sdkRequest.hideStoreCardSwitch = false
        XCTAssertFalse(sdkRequest.hideStoreCardSwitch)
    }
}
