//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine
import PureduxStore

struct EnvironmentStorePresentingView<AppState, Action, Props, Content>: View
    where
    Content: View {

    @EnvironmentObject private var store: RootEnvStore<AppState, Action>

    let presenter: Presenter<AppState, Action, Props, Content>

    var body: some View {
        PresentingView(
            store: store.store(),
            presenter: presenter
        )
    }
}



