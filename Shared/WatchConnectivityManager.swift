import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject,  WCSessionDelegate {
    
    enum MonitorState {
        case notStarted, launching, running, errorOccur(Error)
    }
    
    static var shared: WatchConnectivityManager {
        WatchConnectivityManager.sharedInstance
    }
    
    private static let sharedInstance = WatchConnectivityManager()
    
    private override init() {
        super.init()
    }
    
    private var defaultSession: WCSession {
        return WCSession.default
    }
    
    var monitorState: MonitorState = .notStarted
    private var sessionActivationCompletionHandlers = [((WCSession) -> Void)]()
    private var messageHandlers = [MessageHandler]()
    
    func addMessageHandler(_ messageHandler: MessageHandler) {
        messageHandlers.append(messageHandler)
    }
    
    fileprivate func removeMessageHandler(_ messageHandler: MessageHandler) {
        if let index = messageHandlers.firstIndex(of: messageHandler) {
            messageHandlers.remove(at: index)
        }
    }
    
    func activate() {
        defaultSession.delegate = self
        defaultSession.activate()
    }
    
    func fetchActivatedSession(handler: @escaping (WCSession) -> Void) {
        
        activate()
        
        if defaultSession.activationState == .activated {
            handler(defaultSession)
        } else {
            sessionActivationCompletionHandlers.append(handler)
        }
    }
    
//    func fetchReachableState(handler: @escaping (Bool) -> Void) {
//        fetchActivatedSession { session in
//            handler(session.isReachable)
//        }
//    }
    
    func send(_ message: [MessageKey : Any]) {
        if WCSession.isSupported() {
            fetchActivatedSession { session in
                session.sendMessage(self.sessionMessage(for: message), replyHandler: nil)
            }
        }
    }
    
//    func transfer(_ message: [MessageKey : Any]) {
//        fetchActivatedSession { session in
//            session.transferUserInfo(self.sessionMessage(for: message))
//        }
//    }
    
    private func sessionMessage(for message: [MessageKey : Any]) -> [String : Any] {
        var sessionMessage = [String : Any]()
        message.forEach { sessionMessage[$0.key.rawValue] = $0.value }
        return sessionMessage
    }
    
    private func handle(_ receivedMessage: [String : Any]) {
        
        var convertedMessage = [MessageKey: Any]()
        receivedMessage.forEach { convertedMessage[MessageKey($0.key)] = $0.value }
        
        DispatchQueue.main.async {
            self.messageHandlers.forEach { $0.handler(convertedMessage) }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
        
        if activationState == .activated {
            DispatchQueue.main.async {
                self.sessionActivationCompletionHandlers.forEach { $0(session) }
                self.sessionActivationCompletionHandlers.removeAll()
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print(session)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handle(message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handle(userInfo)
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        // support quick switching between Apple Watch devices in the iOS app
        defaultSession.activate()
    }
    #endif
    
    struct MessageKey: RawRepresentable, Hashable {
        
        private static var hashDictionary = [String : Int]()
        let rawValue: String
        let hashValue: Int
        
        init(_ rawValue: String) {
            self.rawValue = rawValue
            self.hashValue = rawValue.hashValue
        }
        
        init(rawValue: String) {
            self.rawValue = rawValue
            self.hashValue = rawValue.hashValue
        }
        
        static func ==(lhs: MessageKey, rhs: MessageKey) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    struct MessageHandler: Hashable {
        
        fileprivate let uuid: UUID
        
        fileprivate let handler: (([MessageKey : Any]) -> Void)
        
        let hashValue: Int
        
        init(handler: @escaping (([MessageKey : Any]) -> Void)) {
            self.handler = handler
            self.uuid = UUID()
            self.hashValue = self.uuid.hashValue
        }
        
        func invalidate() {
            let manager: WatchConnectivityManager? = WatchConnectivityManager.shared
            manager?.removeMessageHandler(self)
        }
        
        static func ==(lhs: MessageHandler, rhs: MessageHandler) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
    
}
