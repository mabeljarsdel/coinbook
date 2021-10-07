//import Foundation
//
//typealias Chan = Chan2
//
//infix operator <-
//extension Chan2 {
//    static func <- (_ x:Chan2, _ m:Message) {
//        x.queue(m)
//    }
//}
//
//final class Chan2<Message>: AsyncSequence {
//    typealias AsyncIterator = AsyncStream<Message>.AsyncIterator
//    typealias Element = Message
//    
//    private let procq = DispatchQueue(label: "chan")
//    private let sema = DispatchSemaphore(value: 0)
//    private var msgq = [Message]()
//    func queue(_ x:Message) {
//        withCheckedContinuation(<#T##body: (CheckedContinuation<T, Never>) -> Void##(CheckedContinuation<T, Never>) -> Void#>)
//        procq.async { [self] in
//            self.msgq.append(x)
//            self.sema.signal()
//        }
//    }
//    func run() -> AsyncStream<Message> {
//        AsyncStream { [procq] cont in
//            procq.async { [self] in
//                while true {
//                    self.sema.wait()
//                    for m in msgq {
//                        cont.yield(m)
//                    }
//                    msgq.removeAll()
//                }
//            }
//        }
//    }
//    func makeAsyncIterator() -> AsyncStream<Message>.AsyncIterator {
//        run().makeAsyncIterator()
//    }
//}
