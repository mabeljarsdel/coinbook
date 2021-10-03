import Foundation

public enum Issue: Error {
    case badURLCode(String)
    case bitMEX(BitMEXIssue)
    public enum BitMEXIssue: Error {
        case badFormMessage(message:String, codingPath:[CodingKey])
        case serverError(String)
    }
}
