import ComposableArchitecture
import MultipeerConnectivity

public typealias InvitationHandler = (Bool, MCSession?) -> Void

public struct Advertiser {
    public enum Action: Equatable {
        public static func == (lhs: Advertiser.Action, rhs: Advertiser.Action) -> Bool {
            switch (lhs, rhs) {
            case let (.didNotStartAdvertisingPeer(lError), .didNotStartAdvertisingPeer(rError)):
                return lError == rError
            case let (.didReceiveInvitationFromPeer(lPeerID, lData, _), .didReceiveInvitationFromPeer(rPeerID, rData, _)):
                return lPeerID == rPeerID && lData == rData
            default:
                return false
            }
        }

        case didNotStartAdvertisingPeer(Error)
        case didReceiveInvitationFromPeer(MCPeerID, Data?, InvitationHandler)
    }

    var create: (AnyHashable, MCPeerID, String) -> Effect<Action, Never> = { _, _, _ in _unimplemented("create") }

    var startAdvertising: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("startAdvertising") }

    var stopAdvertising: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("stopAdvertising") }

    public func create(id: AnyHashable, peerID: MCPeerID, serviceType: String) -> Effect<Action, Never> {
        create(id, peerID, serviceType)
    }

    public func startAdvertising(id: AnyHashable) -> Effect<Never, Never> {
        startAdvertising(id)
    }

    public func stopAdvertising(id: AnyHashable) -> Effect<Never, Never> {
        stopAdvertising(id)
    }

    //    public struct Properties {
    //        let peerID: MCPeerID = MCPeerID(displayName: ProcessInfo.processInfo.hostName)
    //    }

    public struct Error: Swift.Error, Equatable {
        public let error: NSError

        public init(_ error: Swift.Error) {
            self.error = error as NSError
        }
    }
}

public struct Browser {
    public enum Action: Equatable {
        case didNotStartBrowsingForPeers(Error)
        case foundPeer(MCPeerID, [String:String]?)
        case lostPeer(MCPeerID)
    }

    var create: (AnyHashable, MCPeerID, String) -> Effect<Action, Never> = { _, _, _ in _unimplemented("create") }

    var startBrowsing: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("startBrowsing") }

    var stopBrowsing: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("stopBrowsing") }

    var invitePeer: (AnyHashable, MCPeerID, MCSession, Data?, TimeInterval) -> Effect<Never, Never> = { _, _, _, _, _ in _unimplemented("invitePeer") }

    public func create(id: AnyHashable, peerID: MCPeerID, serviceType: String) -> Effect<Action, Never> {
        create(id, peerID, serviceType)
    }

    public func startBrowsing(id: AnyHashable) -> Effect<Never, Never> {
        startBrowsing(id)
    }

    public func stopBrowsing(id: AnyHashable) -> Effect<Never, Never> {
        stopBrowsing(id)
    }

    public func invitePeer(id: AnyHashable, peerID: MCPeerID, to session: MCSession, withContext: Data?, timeout: TimeInterval)
    -> Effect<Never, Never> {
        invitePeer(id, peerID, session, withContext, timeout)
    }

    public struct Error: Swift.Error, Equatable {
        public let error: NSError

        public init(_ error: Swift.Error) {
            self.error = error as NSError
        }
    }
}

public struct Session {
    public enum Action: Equatable {
        case created(MCSession)

        // from delegate
        case didChange(MCSessionState)
    }

    var create: (AnyHashable, MCPeerID) -> Effect<Action, Never> = { _, _ in _unimplemented("create") }

    public func create(id: AnyHashable, peerID: MCPeerID) -> Effect<Action, Never> {
        create(id, peerID)
    }
}
