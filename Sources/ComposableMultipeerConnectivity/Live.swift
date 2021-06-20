import ComposableArchitecture
import Combine
import MultipeerConnectivity
import os.log

private struct AdvertiserDependencies {
    let advertiser: MCNearbyServiceAdvertiser
    let delegate: MCNearbyServiceAdvertiserDelegate
}

private struct BrowserDependencies {
    let browser: MCNearbyServiceBrowser
    let delegate: MCNearbyServiceBrowserDelegate
}

private struct SessionDependencies {
    let session: MCSession
    let delegate: MCSessionDelegate
}

private var advertiserDependencies: [AnyHashable: AdvertiserDependencies] = [:]
private var browserDependencies: [AnyHashable: BrowserDependencies] = [:]
private var sessionDependencies: [AnyHashable: SessionDependencies] = [:]

extension Advertiser {
    public static let live: Advertiser = { () -> Advertiser in
        var advertiser = Advertiser()

        advertiser.create = { id, peerID, serviceType in
            os_log("Creating Advertiser", type: .debug)
            return Effect.run { subscriber in
                os_log("Running Advertiser", type: .debug)
                let advertiser = MCNearbyServiceAdvertiser(
                    peer: peerID,
                    discoveryInfo: nil,
                    serviceType: serviceType)
                let delegate = AdvertiserDelegate(subsriber: subscriber)
                advertiser.delegate = delegate

                advertiserDependencies[id] = AdvertiserDependencies(
                    advertiser: advertiser,
                    delegate: delegate
                )

                return AnyCancellable {
                    os_log("Deleting Advertiser Dependencies", type: .debug)
                    advertiserDependencies[id] = nil
                }
            }
        }

        advertiser.startAdvertising = { id in
            .fireAndForget {
                os_log("Start Advertising", type: .debug)
                advertiserDependencies[id]?.advertiser.startAdvertisingPeer()
            }
        }

        advertiser.stopAdvertising = { id in
            .fireAndForget {
                os_log("Stop Advertising", type: .debug)
                advertiserDependencies[id]?.advertiser.stopAdvertisingPeer()
            }
        }

        return advertiser
    }()
}

extension Browser {
    public static let live: Browser = { () -> Browser in
        var browser = Browser()

        browser.create = { id, peerID, serviceType in
            os_log("Creating Browser", type: .debug)
            return Effect.run { subscriber in
                os_log("Running Browser", type: .debug)
                let browser = MCNearbyServiceBrowser(
                    peer: peerID,
                    serviceType: serviceType)
                let delegate = BrowserDelegate(subscriber: subscriber)
                browser.delegate = delegate

                browserDependencies[id] = BrowserDependencies(
                    browser: browser,
                    delegate: delegate
                )

                return AnyCancellable {
                    os_log("Deleting Browser Dependencies", type: .debug)
                    browserDependencies[id] = nil
                }
            }
        }

        browser.startBrowsing = { id in
            return .fireAndForget {
                os_log("Start Browsing", type: .debug)
                dump(browserDependencies)
                browserDependencies[id]?.browser.startBrowsingForPeers()
            }
        }

        browser.stopBrowsing = { id in
            return .fireAndForget {
                os_log("Stop Browsing", type: .debug)
                browserDependencies[id]?.browser.stopBrowsingForPeers()
            }
        }

        browser.invitePeer = { id, peerID, session, data, timeout in
            return .fireAndForget {
                os_log("Sending invite to session %@", type: .debug, String(describing: session))
                browserDependencies[id]?.browser
                    .invitePeer(
                        peerID,
                        to: session,
                        withContext: data,
                        timeout: timeout
                    )
            }
        }

        return browser
    }()
}

extension Session {
    public static let live: Session = { () -> Session in
        var session = Session()

        session.create = { id, peerID in
            Effect.run { subscriber in
                os_log("Creating Session", type: .debug)
                let session = MCSession(peer: peerID)
                let delegate = SessionDelegate(subscriber: subscriber)
                session.delegate = delegate

                sessionDependencies[id] = SessionDependencies(
                    session: session,
                    delegate: delegate
                )

                DispatchQueue.main.async {
                    subscriber.send(.created(session))
                }

                return AnyCancellable {
                    os_log("Deleting Session Depenencies", type: .debug)
                    sessionDependencies[id] = nil
                }
            }
        }

        return session
    }()
}

class AdvertiserDelegate: NSObject, MCNearbyServiceAdvertiserDelegate {
    private var subscriber: Effect<Advertiser.Action, Never>.Subscriber

    init(subsriber: Effect<Advertiser.Action, Never>.Subscriber) {
        self.subscriber = subsriber
        super.init()
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        subscriber.send(.didNotStartAdvertisingPeer(Advertiser.Error(error)))
        print(#function)
        print(error)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print(#function)
        subscriber.send(.didReceiveInvitationFromPeer(peerID, context, invitationHandler))
    }
}

class BrowserDelegate: NSObject, MCNearbyServiceBrowserDelegate {
    private var subscriber: Effect<Browser.Action, Never>.Subscriber

    init(subscriber: Effect<Browser.Action, Never>.Subscriber) {
        self.subscriber = subscriber
        super.init()
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(#function)
        print(error)
//        subscriber.send(.didNotStartBrowsingForPeers(error))
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        subscriber.send(.foundPeer(peerID, info))
        print(#function)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        subscriber.send(.lostPeer(peerID))
        print(#function)
    }
}

class SessionDelegate: NSObject, MCSessionDelegate {
    private var subscriber: Effect<Session.Action, Never>.Subscriber

    init(subscriber: Effect<Session.Action, Never>.Subscriber) {
        self.subscriber = subscriber
        super.init()
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print(#function)
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(#function)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print(#function)
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print(#function)
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print(#function)
    }
}
