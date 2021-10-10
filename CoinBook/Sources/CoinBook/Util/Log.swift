import Foundation

/// Placeholder for logging facility.
func log<T>(_ x:@autoclosure() -> T) {
    print(x())
}

/// Placeholder for debug-logging facility.
func debugLog<T>(_ x:@autoclosure() -> T) {
    #if DEBUG
    print(x())
    #endif
}

/// Placeholder for debug-logging facility.
func verboseLog<T>(_ x:@autoclosure() -> T) {
    #if VERBOSE
//    dump(x())
    #endif
}

/// Placeholder for debug-logging facility.
func verboseDump<T>(_ x:@autoclosure() -> T) {
    #if VERBOSE
//    dump(x())
    #endif
}







func perfLog<T>(_ msg:@autoclosure() -> T, _ file: @autoclosure() -> String = #file) {
//    let time = Date().timeIntervalSince1970
//    let name = URL(fileURLWithPath: file()).deletingPathExtension().lastPathComponent
//    print("\(time) \(name): \(msg())")
}
