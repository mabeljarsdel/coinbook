import XCTest
@testable import CoinBook

final class StateOrderPushTests: XCTestCase {
    func testOrderPushgToState() throws {
        let filepath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("LiveServiceDataSample")
        let sampleCode = try String(contentsOf: filepath, encoding: .utf8)
        let sampleCodeLine = sampleCode.split(separator: "\n")
        let jsondec = JSONDecoder()
        
        var state = State()
        for line in sampleCodeLine {
            guard !line.isEmpty else { continue }
            let d = line.data(using: .utf8) ?? Data()
            let m = try jsondec.decode(NABitMEXChannel.Report.self, from: d)
            switch m {
            case let .table(x):
                switch x.rows {
                case let .orderBookL2(rows):
                    for row in rows {
                        dump(row)
                        state.push(State.Order.from(bitMEX: row))
                    }
                case let .trade(rows):
                    for row in rows {
                        dump(row)
                        state.push(State.Trade.from(bitMEX: row))
                    }
                case .unknown:
                    break
                }
            default:
                break
            }
        }
        dump(state)
    }
}
