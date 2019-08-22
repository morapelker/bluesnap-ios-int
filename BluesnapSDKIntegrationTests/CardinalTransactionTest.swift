

import XCTest
@testable import BluesnapSDK

class CardinalTransactionTest: XCTestCase {
    let email = "test@sdk.com"

    let purchaseCCData = ["cardLastFourDigits": "1111", "expirationMonth": "10","expirationYear": "2020", "cardType": "VISA"]

    let purchaseBillingData = [ "firstName": "La", "lastName": "Fleur", "address1": "555 Broadway street",
                                "city": "New York", "zip": "3abc 324a", "country": "us", "state": "NY"]

    let purchaseShippingData = ["firstName": "Taylor", "lastName": "Love", "address1": "AddressTest",
                                "city": "CityTest", "zip": "12345", "country": "br", "state": "RJ"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCardinalTransaction() {
        let shopper = MockShopper(creditCardInfo: [(purchaseBillingData,purchaseCCData)], email: email, shippingContactInfo: purchaseShippingData, fullBillingRequired: true, emailRequired: true, shippingRequired: true)

        let tokenizeRequest = BSTokenizeRequest()
        //let cardinalManager = BSCardinalManager.instance.
        BSCardinalManager.instance.setupCardinal(completion: {

        })
//
//        tokenizeRequest.paymentDetails = BSTokenizeNewCCDetails(ccNumber: "4111 1111 1111 1111", cvv: "123", ccType: nil, expDate: "\(purchaseCCData["expirationMonth"]!)/\(purchaseCCData["expirationYear"]!)")
//        tokenizeRequest.billingDetails = BSBillingAddressDetails(email: email, name: "\(purchaseBillingData["firstName"]!) \(purchaseBillingData["lastName"]!)", address: purchaseBillingData["address1"], city: purchaseBillingData["city"], zip: purchaseBillingData["zip"], country: purchaseBillingData["country"]?.uppercased(), state: purchaseBillingData["state"])
//        tokenizeRequest.shippingDetails = BSShippingAddressDetails(name: "\(purchaseShippingData["firstName"]!) \(purchaseShippingData["lastName"]!)", address: purchaseShippingData["address1"], city: purchaseShippingData["city"], zip: purchaseShippingData["zip"], country: purchaseShippingData["country"]?.uppercased(), state: purchaseShippingData["state"])
//
//        let semaphore = DispatchSemaphore(value: 0)
//        BSIntegrationTestingAPIHelper.createToken(completion: { bsToken, error in
//
//            // Setup cardinal
//            cardinalManager.setupCardinalSession(bsToken: bsToken!)
//            cardinalManager.getCardinalJWT(bsToken: bsToken!)
//            XCTAssertNotNil(cardinalManager.cardinalToken?.jwtStr)
//
//        })
//        semaphore.wait()
//
//
//        let cardinalRequest: BS3DSAuthRequest!  = BS3DSAuthRequest(currencyCode: "USD", amount: "20", jwt: cardinalManager.cardinalToken?.jwtStr)
//
//
//
    }


}


