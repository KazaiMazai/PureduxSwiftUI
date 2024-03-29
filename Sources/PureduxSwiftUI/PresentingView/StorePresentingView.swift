//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import SwiftUI
import Combine

struct StorePresentingView<Store, AppState, Action, Props, Content>: View
    where
    Content: View,
    Store: ViewStore,
    Store.AppState == AppState,
    Store.Action == Action {

    let store: Store

    @State private var currentProps: Props?
    @State private var propsPublisher: AnyPublisher<Props, Never>?

    let props: (_ state: AppState, _ store: Store) -> Props
    let content: (_ props: Props) -> Content

    let distinctStateChangesBy: (AppState, AppState) -> Bool

    var body: some View {
        makeContent()
            .onReceive(propsPublisher) { self.currentProps = $0 }
            .onAppear { propsPublisher = makePropsPublisher() }
    }
}

private extension View {
    @ViewBuilder
    func onReceive<P>(_ publisher: P?, perform action: @escaping (P.Output) -> Void) -> some View where P : Publisher, P.Failure == Never {
        if let publisher = publisher {
            onReceive(publisher, perform: action)
        } else {
            self
        }
    }
}

private extension StorePresentingView {
    @ViewBuilder
    func makeContent() -> some View {
        if let props = currentProps {
            content(props)
        } else {
            Color.clear
        }
    }

    func makePropsPublisher() -> AnyPublisher<Props, Never> {
        store.statePublisher
            .removeDuplicates(by: distinctStateChangesBy)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
