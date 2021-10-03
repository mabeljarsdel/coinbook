import Foundation

/// Placeholder for logging facility.
func log<T>(_ x:T) {
    print(x)
}

/// Placeholder for debug-logging facility.
func debugLog<T>(_ x:T) {
    #if DEBUG
    print(x)
    #endif
}

/// Placeholder for debug-logging facility.
func verboseLog<T>(_ x:T) {
    #if VERBOSE
    #endif
}

/// Placeholder for debug-logging facility.
func verboseDump<T>(_ x:T) {
    #if VERBOSE
//    dump(x)
    #endif
}
