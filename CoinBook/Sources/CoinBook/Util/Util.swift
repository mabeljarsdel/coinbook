import Foundation

extension URL {
    static func from(expression s:String) throws -> URL {
        guard let u = URL(string: s) else { throw Issue.badURLCode(s) }
        return u
    }
}

func noop<T>(_:T) {}

/// Asserts current executing GCDQ.
/// Panics if current GCDQ is not designated one.
/// No-op in optimized build.
func assertGCDQ(_ gcdq: @autoclosure() -> DispatchQueue) {
    #if DEBUG
    dispatchPrecondition(condition: .onQueue(gcdq()))
    #endif
}

extension String {

}
