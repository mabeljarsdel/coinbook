import Foundation

extension AsyncStream {
    func throttle(interval x:TimeInterval) -> AsyncStream {
        let thro = Throttle<Element>(interval: x)
        return AsyncStream { [self,thro] continuation in
            Task {
                for await m in self {
                    await thro.queue(m)
                }
            }
            Task {
                for await m in thro.run() {
                    continuation.yield(m)
                }
            }
        }
    }
}

extension AsyncThrowingStream {
    func throttle(interval x:TimeInterval) -> AsyncThrowingStream<Element,Error> {
        let thro = Throttle<Element>(interval: x)
        return AsyncThrowingStream<Element,Error> { [self,thro] continuation in
            Task {
                do {
                    for try await m in self {
                        await thro.queue(m)
                    }
                }
                catch let err {
                    continuation.finish(throwing: err)
                }
            }
            Task {
                for await m in thro.run() {
                    continuation.yield(m)
                }
            }
        }
    }
}




extension AsyncThrowingStream.Continuation {
    func send(_ x:Result<Element,Failure>) {
        switch x {
        case let .failure(err): finish(throwing: err)
        case let .success(x): yield(x)
        }
    }
}
