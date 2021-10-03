import Foundation
import XCTest
@testable import CoinBook

final class BitMEXTests: XCTestCase {
    func testDecoding() throws {
        let jc = JSONDecoder()
        let ms = samples.split(separator: "\n")
        for m in ms {
            let d = m.data(using: .utf8) ?? Data()
            let j = try jc.decode(BitMEXChannel.Report.self, from: d)
            print(j)
        }
    }
}

private let samples =
"""
{"info":"Welcome to the BitMEX Realtime API.","version":"2021-09-28T05:12:39.000Z","timestamp":"2021-10-03T04:48:57.160Z","docs":"https://www.bitmex.com/app/wsAPI","limit":{"remaining":38}}
{"success":true,"subscribe":"trade:XBTUSD","request":{"op":"subscribe","args":["trade:XBTUSD"]}}
{"table":"trade","action":"partial","keys":[],"types":{"timestamp":"timestamp","symbol":"symbol","side":"symbol","size":"long","price":"float","tickDirection":"symbol","trdMatchID":"guid","grossValue":"long","homeNotional":"float","foreignNotional":"float"},"foreignKeys":{"symbol":"instrument","side":"side"},"attributes":{"timestamp":"sorted","symbol":"grouped"},"filter":{"symbol":"XBTUSD"},"data":[{"timestamp":"2021-10-03T04:48:57.025Z","symbol":"XBTUSD","side":"Buy","size":1000,"price":47888.5,"tickDirection":"PlusTick","trdMatchID":"dab03d1e-f1f6-ffd3-e241-a57473a6431f","grossValue":2088180,"homeNotional":0.0208818,"foreignNotional":1000}]}
{"table":"trade","action":"insert","data":[{"timestamp":"2021-10-03T04:48:58.147Z","symbol":"XBTUSD","side":"Buy","size":3300,"price":47898.5,"tickDirection":"PlusTick","trdMatchID":"7ec3ec81-3c9c-f610-7170-309e393441eb","grossValue":6889575,"homeNotional":0.06889575,"foreignNotional":3300}]}
{"table":"trade","action":"insert","data":[{"timestamp":"2021-10-03T04:49:05.325Z","symbol":"XBTUSD","side":"Buy","size":500,"price":47899.5,"tickDirection":"PlusTick","trdMatchID":"cce6fe48-db19-2343-d435-88625ad1a70f","grossValue":1043850,"homeNotional":0.0104385,"foreignNotional":500},{"timestamp":"2021-10-03T04:49:05.325Z","symbol":"XBTUSD","side":"Buy","size":100,"price":47899.5,"tickDirection":"ZeroPlusTick","trdMatchID":"e8161493-00d2-089c-4aa6-3fd2cd6cdb03","grossValue":208770,"homeNotional":0.0020877,"foreignNotional":100},{"timestamp":"2021-10-03T04:49:05.325Z","symbol":"XBTUSD","side":"Buy","size":700,"price":47899.5,"tickDirection":"ZeroPlusTick","trdMatchID":"bc3b6d3b-a230-e2b1-088f-3737dbefe7f9","grossValue":1461390,"homeNotional":0.0146139,"foreignNotional":700},{"timestamp":"2021-10-03T04:49:05.325Z","symbol":"XBTUSD","side":"Buy","size":200,"price":47899.5,"tickDirection":"ZeroPlusTick","trdMatchID":"b8fde48e-60db-7c68-af13-77ebf13cbfbe","grossValue":417540,"homeNotional":0.0041754,"foreignNotional":200},{"timestamp":"2021-10-03T04:49:05.325Z","symbol":"XBTUSD","side":"Buy","size":2200,"price":47899.5,"tickDirection":"ZeroPlusTick","trdMatchID":"b8f62a31-3c7a-d435-83de-b06f827c8ded","grossValue":4592940,"homeNotional":0.0459294,"foreignNotional":2200},{"timestamp":"2021-10-03T04:49:05.325Z","symbol":"XBTUSD","side":"Buy","size":7400,"price":47899.5,"tickDirection":"ZeroPlusTick","trdMatchID":"bdb1d5fd-425b-5d72-71c1-55c7607260d2","grossValue":15448980,"homeNotional":0.1544898,"foreignNotional":7400},{"timestamp":"2021-10-03T04:49:05.325Z","symbol":"XBTUSD","side":"Buy","size":200,"price":47899.5,"tickDirection":"ZeroPlusTick","trdMatchID":"2133d1b9-ba1f-653d-2bd4-3f67261879eb","grossValue":417540,"homeNotional":0.0041754,"foreignNotional":200}]}
{"info":"Welcome to the BitMEX Realtime API.","version":"2021-09-28T05:12:39.000Z","timestamp":"2021-10-03T05:47:59.805Z","docs":"https://www.bitmex.com/app/wsAPI","limit":{"remaining":36}}
{"success":true,"subscribe":"orderBookL2_25:XBTUSD","request":{"op":"subscribe","args":["orderBookL2_25:XBTUSD"]}}
{"table":"orderBookL2_25","action":"partial","keys":["symbol","id","side"],"types":{"symbol":"symbol","id":"long","side":"symbol","size":"long","price":"float"},"foreignKeys":{"symbol":"instrument","side":"side"},"attributes":{"symbol":"parted","id":"sorted"},"filter":{"symbol":"XBTUSD"},"data":[{"symbol":"XBTUSD","id":8795192450,"side":"Sell","size":5000,"price":48075.5},{"symbol":"XBTUSD","id":8795192500,"side":"Sell","size":5600,"price":48075},{"symbol":"XBTUSD","id":8795192550,"side":"Sell","size":12000,"price":48074.5},{"symbol":"XBTUSD","id":8795192650,"side":"Sell","size":3000,"price":48073.5},{"symbol":"XBTUSD","id":8795192800,"side":"Sell","size":3000,"price":48072},{"symbol":"XBTUSD","id":8795193000,"side":"Sell","size":12700,"price":48070},{"symbol":"XBTUSD","id":8795193100,"side":"Sell","size":9600,"price":48069},{"symbol":"XBTUSD","id":8795193150,"side":"Sell","size":133900,"price":48068.5},{"symbol":"XBTUSD","id":8795193250,"side":"Sell","size":12000,"price":48067.5},{"symbol":"XBTUSD","id":8795193350,"side":"Sell","size":237900,"price":48066.5},{"symbol":"XBTUSD","id":8795193400,"side":"Sell","size":9000,"price":48066},{"symbol":"XBTUSD","id":8795193500,"side":"Sell","size":4700,"price":48065},{"symbol":"XBTUSD","id":8795193600,"side":"Sell","size":600,"price":48064},{"symbol":"XBTUSD","id":8795193700,"side":"Sell","size":100,"price":48063},{"symbol":"XBTUSD","id":8795193750,"side":"Sell","size":38500,"price":48062.5},{"symbol":"XBTUSD","id":8795193800,"side":"Sell","size":18800,"price":48062},{"symbol":"XBTUSD","id":8795193950,"side":"Sell","size":33600,"price":48060.5},{"symbol":"XBTUSD","id":8795194050,"side":"Sell","size":32000,"price":48059.5},{"symbol":"XBTUSD","id":8795194200,"side":"Sell","size":39500,"price":48058},{"symbol":"XBTUSD","id":8795194400,"side":"Sell","size":33300,"price":48056},{"symbol":"XBTUSD","id":8795194550,"side":"Sell","size":100,"price":48054.5},{"symbol":"XBTUSD","id":8795194650,"side":"Sell","size":15100,"price":48053.5},{"symbol":"XBTUSD","id":8795194750,"side":"Sell","size":100,"price":48052.5},{"symbol":"XBTUSD","id":8795194850,"side":"Sell","size":14800,"price":48051.5},{"symbol":"XBTUSD","id":8795195650,"side":"Sell","size":76200,"price":48043.5},{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":209900,"price":48043},{"symbol":"XBTUSD","id":8795196150,"side":"Buy","size":1300,"price":48038.5},{"symbol":"XBTUSD","id":8795196500,"side":"Buy","size":6000,"price":48035},{"symbol":"XBTUSD","id":8795196600,"side":"Buy","size":50000,"price":48034},{"symbol":"XBTUSD","id":8795196650,"side":"Buy","size":168900,"price":48033.5},{"symbol":"XBTUSD","id":8795196700,"side":"Buy","size":100,"price":48033},{"symbol":"XBTUSD","id":8795196800,"side":"Buy","size":125000,"price":48032},{"symbol":"XBTUSD","id":8795196850,"side":"Buy","size":17900,"price":48031.5},{"symbol":"XBTUSD","id":8795196900,"side":"Buy","size":18400,"price":48031},{"symbol":"XBTUSD","id":8795196950,"side":"Buy","size":120700,"price":48030.5},{"symbol":"XBTUSD","id":8795197000,"side":"Buy","size":73000,"price":48030},{"symbol":"XBTUSD","id":8795197050,"side":"Buy","size":35000,"price":48029.5},{"symbol":"XBTUSD","id":8795197100,"side":"Buy","size":100,"price":48029},{"symbol":"XBTUSD","id":8795197150,"side":"Buy","size":70800,"price":48028.5},{"symbol":"XBTUSD","id":8795197300,"side":"Buy","size":63000,"price":48027},{"symbol":"XBTUSD","id":8795197350,"side":"Buy","size":111400,"price":48026.5},{"symbol":"XBTUSD","id":8795197450,"side":"Buy","size":98500,"price":48025.5},{"symbol":"XBTUSD","id":8795197500,"side":"Buy","size":64000,"price":48025},{"symbol":"XBTUSD","id":8795197600,"side":"Buy","size":3000,"price":48024},{"symbol":"XBTUSD","id":8795197650,"side":"Buy","size":144400,"price":48023.5},{"symbol":"XBTUSD","id":8795197700,"side":"Buy","size":9600,"price":48023},{"symbol":"XBTUSD","id":8795197750,"side":"Buy","size":1000,"price":48022.5},{"symbol":"XBTUSD","id":8795197800,"side":"Buy","size":100700,"price":48022},{"symbol":"XBTUSD","id":8795197950,"side":"Buy","size":100,"price":48020.5},{"symbol":"XBTUSD","id":8795198000,"side":"Buy","size":20800,"price":48020}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795193100,"side":"Sell","size":230900},{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":210000},{"symbol":"XBTUSD","id":8795197750,"side":"Buy","size":65200}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795192450,"side":"Sell"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795193800,"side":"Sell","size":38800}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795195150,"side":"Sell","size":43100,"price":48048.5}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795193700,"side":"Sell"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195650,"side":"Sell","size":76300},{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":170000}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795192450,"side":"Sell","size":5000,"price":48075.5}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":210000},{"symbol":"XBTUSD","id":8795197750,"side":"Buy","size":1000}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795197750,"side":"Buy","size":65200}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795195150,"side":"Sell"}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795194450,"side":"Sell","size":43100,"price":48055.5}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":170000}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":210000}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795198000,"side":"Buy"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795197750,"side":"Buy","size":65700},{"symbol":"XBTUSD","id":8795197800,"side":"Buy","size":101200}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795197900,"side":"Buy","size":600,"price":48021}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195650,"side":"Sell","size":75700}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795197950,"side":"Buy"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":170000},{"symbol":"XBTUSD","id":8795197300,"side":"Buy","size":60000}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795197250,"side":"Buy","size":3000,"price":48027.5}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795192450,"side":"Sell"},{"symbol":"XBTUSD","id":8795197900,"side":"Buy"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795193800,"side":"Sell","size":18800},{"symbol":"XBTUSD","id":8795197750,"side":"Buy","size":65200},{"symbol":"XBTUSD","id":8795197800,"side":"Buy","size":100700}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795193550,"side":"Sell","size":20000,"price":48064.5},{"symbol":"XBTUSD","id":8795197950,"side":"Buy","size":100,"price":48020.5}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":210000}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795196650,"side":"Buy"}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795198000,"side":"Buy","size":980600,"price":48020}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795197800,"side":"Buy"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795197500,"side":"Buy","size":164700}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795198050,"side":"Buy","size":15800,"price":48019.5}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795197350,"side":"Buy","size":111500}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795197750,"side":"Buy","size":1000},{"symbol":"XBTUSD","id":8795197950,"side":"Buy","size":65100}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795193950,"side":"Sell"},{"symbol":"XBTUSD","id":8795194200,"side":"Sell"},{"symbol":"XBTUSD","id":8795194400,"side":"Sell"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":170000},{"symbol":"XBTUSD","id":8795197950,"side":"Buy","size":165700}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795193900,"side":"Sell","size":33600,"price":48061},{"symbol":"XBTUSD","id":8795194150,"side":"Sell","size":76500,"price":48058.5},{"symbol":"XBTUSD","id":8795194350,"side":"Sell","size":31300,"price":48056.5}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795194350,"side":"Sell"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":210000}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795194400,"side":"Sell","size":31300,"price":48056}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195650,"side":"Sell","size":76300}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195650,"side":"Sell","size":74100}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795194150,"side":"Sell"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195650,"side":"Sell","size":75600}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795194200,"side":"Sell","size":71500,"price":48058}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795197300,"side":"Buy","size":124100},{"symbol":"XBTUSD","id":8795197950,"side":"Buy","size":100700}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795198050,"side":"Buy"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795197300,"side":"Buy","size":60000}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795197900,"side":"Buy","size":64500,"price":48021}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795193100,"side":"Sell","size":9600},{"symbol":"XBTUSD","id":8795193150,"side":"Sell","size":354500}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795193250,"side":"Sell","size":232600},{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":170000}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795194450,"side":"Sell"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795193150,"side":"Sell","size":133900},{"symbol":"XBTUSD","id":8795195650,"side":"Sell","size":118700},{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":210000}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795192450,"side":"Sell","size":5000,"price":48075.5}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795192450,"side":"Sell"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195650,"side":"Sell","size":75600}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795195500,"side":"Sell","size":43100,"price":48045}]}
{"table":"orderBookL2_25","action":"delete","data":[{"symbol":"XBTUSD","id":8795192500,"side":"Sell"}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795193150,"side":"Sell","size":124700}]}
{"table":"orderBookL2_25","action":"insert","data":[{"symbol":"XBTUSD","id":8795192850,"side":"Sell","size":8200,"price":48071.5}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":170000},{"symbol":"XBTUSD","id":8795197050,"side":"Buy","size":50800}]}
{"table":"orderBookL2_25","action":"update","data":[{"symbol":"XBTUSD","id":8795195700,"side":"Buy","size":210000}]}
"""
