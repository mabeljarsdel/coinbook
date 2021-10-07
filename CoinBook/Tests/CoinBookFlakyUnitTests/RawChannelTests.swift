import Foundation
import XCTest
@testable import CoinBook

final class RawChannelTests: XCTestCase {
    func testWelcome() throws {
        let exp = expectation(description: "Receiving from websocket.")
        let ch = try NonActorRawChannel(address: "wss://www.bitmex.com/realtime")
        let jc = JSONDecoder()
        //{
        //    "info":"Welcome to the BitMEX Realtime API.",
        //    "version":"2021-09-28T05:12:39.000Z",
        //    "timestamp":"2021-10-03T03:53:45.122Z",
        //    "docs":"https://www.bitmex.com/app/wsAPI",
        //    "limit": {
        //        "remaining":37
        //    }
        //}
        struct Info: Codable {
            var info: String
            var version: String
            var timestamp: String
            var docs: URL
            var limit: Limit
            struct Limit: Codable {
                var remaining: Int64
            }
        }
        ch.dispatch { report in
            switch report {
            case let .receiveText(s):
                let d = s.encoded()
                do {
                    let m = try jc.decode(Info.self, from: d)
                    print(m)
                    exp.fulfill()
                }
                catch let err {
                    XCTFail("\(err)")
                }
            default:
                XCTFail("\(report)")
            }
        }
        ch.queue(.sendText("help"))
        waitForExpectations(timeout: 10, handler: nil)
    }
    func testSubscription() throws {
        let exp = expectation(description: "Receiving from websocket.")
        let ch = try NonActorRawChannel(address: "wss://www.bitmex.com/realtime")
        ch.dispatch { report in
            switch report {
            case let .receiveText(s):
                print(s)
                let d = s.encoded()
                do {
                    guard let m = try JSONSerialization.jsonObject(with: d, options: []) as? [String:Any] else {
                        XCTFail("message decoding failure.")
                        return
                    }
                    if m["success"] != nil {
                        print(s)
                        exp.fulfill()
                    }
                }
                catch let err {
                    XCTFail("\(err)")
                }
            default:
                XCTFail("\(report)")
            }
        }
        ch.queue(.sendText("{\"op\":\"subscribe\",\"args\":[\"orderBookL2_25:XBTUSD\"]}"))
        waitForExpectations(timeout: 10, handler: nil)
    }
}








private extension String {
    func encoded() -> Data {
        data(using: .utf8) ?? Data()
    }
}
private extension Data {
    func decoded() -> String {
        String(data: self, encoding: .utf8) ?? ""
    }
}
