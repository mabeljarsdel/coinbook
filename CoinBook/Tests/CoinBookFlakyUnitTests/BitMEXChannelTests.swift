import Foundation
import XCTest
@testable import CoinBook

final class BitMEXChannelTests: XCTestCase {
    func testOrderAndTradeMessageReceiving() throws {
        var exp1 = expectation(description: "Receiving order message from websocket.") as XCTestExpectation?
        var exp2 = expectation(description: "Receiving trade message from websocket.") as XCTestExpectation?
        let chan = try NABitMEXChannel()
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
        chan.queue(.subscribe(topics: [.orderBookL2_XBTUSD, .trade_XBT_USD]))
        waitForExpectations(timeout: 30, handler: nil)
    }
    func testManyMessageDecoding() throws {
        var msgcount = 0
        var exp = expectation(description: "Receiving & decoding 1000 messages from websocket.") as XCTestExpectation?
        let chan = try NABitMEXChannel()
        chan.dispatch { report in
            switch report {
            case .info:
                break
            case let .subscribe(x):
                if !x.success {
                    XCTFail("subscription failure.")
                }
            case let .table(x):
                msgcount += 1
                dump(x)
                if msgcount >= 1000 {
                    exp?.fulfill()
                    exp = nil
                }
            case let .error(err):
                XCTFail("received an error: \(err)")
            }
        }
        chan.queue(.subscribe(topics: [.orderBookL2_XBTUSD, .trade_XBT_USD]))
        waitForExpectations(timeout: 120, handler: nil)
    }
}





