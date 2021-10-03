import Foundation

struct Uniqueness: Equatable, Comparable, Hashable {
    private let mark = Mark()
    init() {}
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(mark).hash(into: &hasher)
    }
    static func == (_ a:Uniqueness, _ b:Uniqueness) -> Bool {
        ObjectIdentifier(a.mark) == ObjectIdentifier(b.mark)
    }
    static func < (_ a:Uniqueness, _ b:Uniqueness) -> Bool {
        ObjectIdentifier(a.mark) < ObjectIdentifier(b.mark)
    }
}

final class Mark {}
