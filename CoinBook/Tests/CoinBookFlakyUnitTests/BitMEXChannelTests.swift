import Foundation
import XCTest
@testable import CoinBook

final class BitMEXChannelTests: XCTestCase {
    func testOrderAndTradeMessageReceiving() throws {
        var exp1 = expectation(description: "Receiving order message from websocket.") as XCTestExpectation?
        var exp2 = expectation(description: "Receiving trade message from websocket.") as XCTestExpectation?
        let chan = try BitMEXChannel()
        chan.dispatch { report in
            switch report {
            case .info:
                break
            case let .subscribe(x):
                if !x.success {
                    XCTFail("subscription failure.")
                }
            case let .table(x):
                switch x.rows {
                case .orderBookL2:
                    print("order message recieved!")
                    exp1?.fulfill()
                    exp1 = nil
                case .trade:
                    print("trade message recieved!")
                    exp2?.fulfill()
                    exp2 = nil
                case .unknown:
                    break
                }
            case .error:
                break
            }
        }
        chan.queue(.subscribe(topics: ["orderBookL2_25:XBTUSD", "trade"]))
        waitForExpectations(timeout: 30, handler: nil)
    }
}





