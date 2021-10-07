import Foundation
import Starscream

final class NonActorRawChannel: NSObject, WebSocketDelegate {
    enum Command {
        case sendText(String)
        case sendData(Data)
    }
    enum Report {
        case receiveText(String)
        case receiveData(Data)
    }
    
    private let processq = DispatchQueue(label: "RawWebSocketChannel")
    private var cast = noop as (Report) -> Void
    
    private let sock: WebSocket
    private var sendTextQueue = [String]()
    private var sendDataQueue = [Data]()
    
    init(address: String) throws {
        let req = URLRequest(url: try URL.from(expression: address))
        sock = WebSocket(request: req)
        super.init()
        sock.delegate = self
        sock.connect()
    }
    deinit {
        sock.disconnect()
    }
    @available(*, unavailable)
    override init() {
        fatalError("unsupported.")
    }
    func queue(_ cmd:Command) {
        processq.async { [weak self] in self?.execute(cmd) }
    }
    func dispatch(_ fx: @escaping (Report) -> Void) {
        processq.async { [weak self] in self?.cast = fx }
    }
    
    private func execute(_ cmd:Command) {
        assertGCDQ(processq)
        switch cmd {
        case let .sendText(s):
            sendTextQueue.append(s)
            if sock.isConnected {
                let q = sendTextQueue
                sendTextQueue.removeAll()
                for qs in q {
                    sock.write(string: qs, completion: nil)
                }
            }
        case let .sendData(d):
            sendDataQueue.append(d)
            if sock.isConnected {
                let q = sendDataQueue
                sendDataQueue.removeAll()
                for qd in q {
                    sock.write(data: qd, completion: nil)
                }
            }
        }
    }
    private func onConnect() {
        assertGCDQ(processq)
        do {
            let q = sendTextQueue
            sendTextQueue.removeAll()
            for qs in q {
                sock.write(string: qs, completion: nil)
            }
        }
        do {
            let q = sendDataQueue
            sendDataQueue.removeAll()
            for qd in q {
                sock.write(data: qd, completion: nil)
            }
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        verboseLog((#function, socket))
        processq.async { [weak self] in self?.onConnect() }
    }
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        verboseLog((#function, socket, error))
    }
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        verboseLog((#function, socket, text))
        processq.async { [weak self] in self?.cast(.receiveText(text)) }
    }
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        verboseLog((#function, socket, data))
        processq.async { [weak self] in self?.cast(.receiveData(data)) }
    }
}
