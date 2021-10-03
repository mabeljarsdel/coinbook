import Foundation

enum Issue: Error {
    case badURLCode(String)
    case bitMEX(BitMEXIssue)
    enum BitMEXIssue: Error {
        case badFormMessage(message:String, codingPath:[CodingKey])
        case serverError(String)
        case missingSizeOrPriceFieldInPartialActionTable(BitMEXChannel.OrderBookL2)
        case badSideValue(BitMEXChannel.OrderBookL2)
        case missingRecordForIDOnUpdateOrDelete(BitMEXChannel.OrderBookL2)
        case missingRecordForIDOnScanningTops(BitMEX.OrderBook.ID)
    }
}
