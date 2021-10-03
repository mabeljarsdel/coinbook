//import Foundation
//import XCTest
//@testable import CoinBook
//
//final class URLSessionWebSocketTaskTests: XCTestCase {
//    func testWelcome() async throws {
//        let ws = URLSession.shared.webSocketTask(with: URL(string: "wss://www.bitmex.com/realtime")!)
//        ws.resume()
//        try await ws.send(.string("help"))
//        let x = try await ws.receive()
//        //{
//        //    "info":"Welcome to the BitMEX Realtime API.",
//        //    "version":"2021-09-28T05:12:39.000Z",
//        //    "timestamp":"2021-10-03T03:53:45.122Z",
//        //    "docs":"https://www.bitmex.com/app/wsAPI",
//        //    "limit": {
//        //        "remaining":37
//        //    }
//        //}
//        struct Info: Codable {
//            var info: String
//            var version: String
//            var timestamp: String
//            var docs: URL
//            var limit: Limit
//            struct Limit: Codable {
//                var remaining: Int64
//            }
//        }
//        switch x {
//        case let .string(s):
//            let jc = JSONDecoder()
//            let d = s.data(using: .utf8) ?? Data()
//            let m = try jc.decode(Info.self, from: d)
//            dump(m)
//        default:
//            XCTFail("unexpected non-string message received.")
//        }
//    }
//    func testSubscription() async throws {
//        let ws = URLSession.shared.webSocketTask(with: URL(string: "wss://www.bitmex.com/realtime")!)
//        ws.resume()
//        try await ws.send(.string("{\"op\":\"subscribe\",\"args\":[\"orderBookL2_25:XBTUSD\"]}"))
//        for _ in 0..<100 {
//            let x = try await ws.receive()
//            dump(x)
//            switch x {
//            case let .string(s):
//                let d = s.data(using: .utf8) ?? Data()
//                guard let m = try JSONSerialization.jsonObject(with: d, options: []) as? [String:Any] else {
//                    XCTFail("message decoding failure.")
//                    return
//                }
//                if m["subscribe"] != nil {
//                    print(s)
//                }
//            default:
//                XCTFail("unexpected non-string message received.")
//            }
//        }
//        XCTFail("could not receive subscription success message in 100 times.")
//    }
//}
//
//
//
//
//
//
//
//
//private extension String {
//    func encoded() -> Data {
//        data(using: .utf8) ?? Data()
//    }
//}
//private extension Data {
//    func decoded() -> String {
//        String(data: self, encoding: .utf8) ?? ""
//    }
//}
