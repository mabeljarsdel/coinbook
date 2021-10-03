//import Foundation
//
//protocol Execute {
//    associatedtype Command
//    func queue(_ m:Command)
//}
//protocol Report {
//    associatedtype Report
//    func dispatch<C:Execute>(_ x:C) where C.Command == Report
//}
//extension Report {
//    func dispatch(_ fx:@escaping(Report)->Void) {
//        dispatch(FuncCallExecute(call: fx))
//    }
//}
//class Process: Execute, Report {
//    init(execute:@escaping(Command,@escaping(Report) -> Void)->Void) {
//        
//    }
//    func queue(_ m: Command) {
//        
//    }
//    func dispatch<C>(_ x: C) where C : Execute, Report == C.Command {
//        
//    }
//}
//
//func process<P>(_ fx:@escaping(I)->(O)) -> Process {
//    
//}
//
//
//
//private struct FuncCallExecute<Message>: Execute {
//    typealias Command = Message
//    let call: (Message)->Void
//    func queue(_ m:Message) {
//        call(m)
//    }
//}
//
//
//
////protocol Consume {
////    associatedtype Input
////    func read(_ m:Input)
////}
////protocol Produce {
////    associatedtype Output
////    func write<C:Consume>(_ x:C) where C.Input == Output
////}
////extension Produce {
////    func write(_ fx:@escaping(Output)->Void) {
////        write(FuncCallConsume(call: fx))
////    }
////}
////protocol Process: Consume, Produce {}
////
////
////
////
////
////private struct FuncCallConsume<Message>: Consume {
////    typealias Input = Message
////    let call: (Message)->Void
////    func read(_ m:Message) {
////        call(m)
////    }
////}
////
////
