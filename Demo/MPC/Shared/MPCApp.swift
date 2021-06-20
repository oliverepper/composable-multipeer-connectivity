//
//  MPCApp.swift
//  Shared
//
//  Created by Oliver Epper on 13.06.21.
//

import SwiftUI
import ComposableArchitecture

@main
struct MPCApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: AppState(),
                    reducer: appReducer,
                    environment: AppEnvironment(
                        advertiser: .live,
                        browser: .live,
                        session: .live
                    )
                )
            )
        }
    }
}
