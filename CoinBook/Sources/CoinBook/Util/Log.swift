//
//  File.swift
//  
//
//  Created by Hoon H. on 2021/10/03.
//

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
