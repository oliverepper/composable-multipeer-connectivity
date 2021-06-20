import ComposableArchitecture
import MultipeerConnectivity
extension Advertiser {
    public static func unimplemented(
        create: @escaping (AnyHashable, MCPeerID, String) -> Effect<Action, Never> = { _, _, _ in
            _unimplemented("create")
        },
        startAdvertising: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("startAdvertising")

        },
        stopAdvertising: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("stopAdvertising")
        }
    ) -> Self {
        Self(
            create: create,
            startAdvertising: startAdvertising,
            stopAdvertising: stopAdvertising
        )
    }
}

extension Browser {
    public static func unimplemented(
        create: @escaping (AnyHashable, MCPeerID, String) -> Effect<Action, Never> = { _, _, _ in
            _unimplemented("create")
        },
        startBrowsing: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("startBrowsing")
        },
        stopBrowsing: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("stopBrowsing")
        },
        invitePeer: @escaping (AnyHashable, MCPeerID, MCSession, Data?, TimeInterval) -> Effect<Never, Never> = { _, _, _, _, _ in
            _unimplemented("invitePeer")
        }
    ) -> Self {
        Self(
            create: create,
            startBrowsing: startBrowsing,
            stopBrowsing: stopBrowsing,
            invitePeer: invitePeer
        )
    }
}

extension Session {
    public static func unimplemented(
        create: @escaping (AnyHashable, MCPeerID) -> Effect<Action, Never> = { _, _ in
            _unimplemented("create")
        }
    ) -> Self {
        Self(
            create: create
        )
    }
}

public func _unimplemented(
    _ function: StaticString, file: StaticString = #file, line: UInt = #line
) -> Never {
    fatalError(
        """
    `\(function)` was called but is not implemented. Be sure to provide an implementation for
    this endpoint when creating the mock.
    """,
        file: file,
        line: line
    )
}
