//
//  ContentView.swift
//  Shared
//
//  Created by Oliver Epper on 13.06.21.
//

import SwiftUI
import ComposableMultipeerConnectivity

struct AppState: Equatable {
    let advertiserPeerID = MCPeerID(displayName: ProcessInfo.processInfo.hostName + "-dev")
    let browserPeerID = MCPeerID(displayName: ProcessInfo.processInfo.hostName + "-dev")
    let serviceType = "Gartenlaube"

    var alert: AlertState<AppAction>? = nil

    var foundPeer: MCPeerID?
    var session: MCSession?
}

enum AppAction: Equatable {
    case advertiser(Advertiser.Action)
    case browser(Browser.Action)
    case session(Session.Action)

    case createAdvertiserBtnTapped
    case startAdvertisingBtnTapped
    case createAndStartAdvertising
    case stopAdvertisingBtnTapped

    case createBrowserBtnTapped
    case startBrowsingBtnTapped
    case createAndStartBrowsing
    case stopBrowsingBtnTapped
    case invitePeerBtnTapped

    case createBrowserSessionBtnTapped

    case alertDismissedBtnTapped
}

struct AppEnvironment {
    var advertiser: Advertiser
    var browser: Browser
    var session: Session
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in

    assert(Thread.isMainThread)

    struct AdvertiserId: Hashable {}
    struct BrowserId: Hashable {}
    struct SessionId: Hashable {}

    switch action {
    case .createAdvertiserBtnTapped:
        return environment.advertiser
            .create(id: AdvertiserId(), peerID: state.advertiserPeerID, serviceType: state.serviceType)
            .map(AppAction.advertiser)

    case .startAdvertisingBtnTapped:
        return environment.advertiser
            .startAdvertising(id: AdvertiserId())
            .fireAndForget()

    case .createAndStartAdvertising:
        return .merge(
            environment.advertiser
                .create(
                    id: AdvertiserId(),
                    peerID: state.advertiserPeerID,
                    serviceType: state.serviceType
                )
                .map(AppAction.advertiser),

            environment.advertiser
                .startAdvertising(id: AdvertiserId())
                .fireAndForget()
        )

    case .stopAdvertisingBtnTapped:
        return environment.advertiser
            .stopAdvertising(id: AdvertiserId())
            .fireAndForget()

    case let .advertiser(.didReceiveInvitationFromPeer(peerId, _, _)):
        return .fireAndForget {
            print("✉️ Received Invitation from \(peerId)")
        }

    case .advertiser:
        return .none

    case .createBrowserBtnTapped:
        return environment.browser
            .create(
                id: BrowserId(),
                peerID: state.browserPeerID,
                serviceType: state.serviceType)
            .map(AppAction.browser)

    case .startBrowsingBtnTapped:
        return environment.browser
            .startBrowsing(id: BrowserId())
            .fireAndForget()

    case .createAndStartBrowsing:
        return .merge(
            environment.browser
                .create(
                    id: BrowserId(),
                    peerID: state.browserPeerID,
                    serviceType: state.serviceType
                )
                .map(AppAction.browser),

            environment.browser
                .startBrowsing(id: BrowserId())
                .fireAndForget()
        )

    case .stopBrowsingBtnTapped:
        return environment.browser
            .stopBrowsing(id: BrowserId())
            .fireAndForget()

    case .createBrowserSessionBtnTapped:
        return environment.session
            .create(id: SessionId(), peerID: state.browserPeerID)
            .map(AppAction.session)

    case .invitePeerBtnTapped:
        guard let peerID = state.foundPeer,
              let session = state.session else {
            return .none
        }
        return environment.browser
            .invitePeer(
                id: BrowserId(),
                peerID: peerID,
                to: session,
                withContext: nil,
                timeout: 1.0)
            .fireAndForget()

    case let .browser(.foundPeer(peerID, nil)):
        state.foundPeer = peerID
        state.alert = .init(
            title: .init("Found Peer"),
            message: .init("Found peer \(peerID)"),
            dismissButton: .default(.init("Ok"), send: .alertDismissedBtnTapped))
        return .fireAndForget {
            print("👋 Found peer: \(peerID)")
        }

    case .browser:
        return .none

    case .alertDismissedBtnTapped:
//        state.alert = nil
        return .none

    case let .session(.created(session)):
        state.session = session
        return .none

    case let .session(.didChange(status)):
        return .fireAndForget {
            print(status)
        }
    }
}

struct ContentView: View {
    let store: Store<AppState, AppAction>

    init(store: Store<AppState, AppAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Group {
                    Button("Create Advertiser") {
                        viewStore.send(.createAdvertiserBtnTapped)
                    }
                    Button("Start Advertising") {
                        viewStore.send(.startAdvertisingBtnTapped)
                    }
                    Button("Create And Start Advertising") {
                        viewStore.send(.createAndStartAdvertising)
                    }
                    Button("Stop Advertising") {
                        viewStore.send(.stopAdvertisingBtnTapped)
                    }
                }
                Spacer()
                Group {
                    Button("Create Browser") {
                        viewStore.send(.createBrowserBtnTapped)
                    }
                    Button("Start Browser") {
                        viewStore.send(.startBrowsingBtnTapped)
                    }
                    Button("Create And Start Browsing") {
                        viewStore.send(.createAndStartBrowsing)
                    }
                    Button("Stop Browser") {
                        viewStore.send(.stopBrowsingBtnTapped)
                    }
                    Button("Create Session") {
                        viewStore.send(.createBrowserSessionBtnTapped)
                    }
                    Button("Invite Peer") {
                        viewStore.send(.invitePeerBtnTapped)
                    }
                }
                Spacer()
            }
            .buttonStyle(.bordered)
            #if os(iOS)
            .font(.title)
            #endif
            .padding()
            .alert(store.scope(state: \.alert), dismiss: .alertDismissedBtnTapped)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: AppState(),
                reducer: appReducer,
                environment: AppEnvironment(
                    advertiser: .unimplemented(),
                    browser: .live,
                    session: .unimplemented()
                )
            )
        )
    }
}
