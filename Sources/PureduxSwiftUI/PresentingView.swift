//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine

struct PresentingView<AppState, Action, SubState, Props, Content>: View
    where Content: View {

    @EnvironmentObject private var store: EnvironmentStore<AppState, Action>

    @State private var currentProps: Props?
    @State private var propsPublisher: AnyPublisher<Props, Never>?

    let substate: (_ state: AppState) -> SubState
    let props: (_ substate: SubState, _ store: EnvironmentStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content
    
    let distinctStateChangesBy: (SubState, SubState) -> Bool

    var body: some View {
        content(currentProps ?? propsForCurrentState())
            .onAppear { propsPublisher = makePropsPublisher() }
            .onReceive(propsPublisher ?? makePropsPublisher()) { self.currentProps = $0 }
    }
}

private extension PresentingView {
    func propsForCurrentState() -> Props {
        props(substate(store.state), store)
    }

    func makePropsPublisher() -> AnyPublisher<Props, Never> {
        store.stateSubject
            .map { substate($0) }
            .removeDuplicates(by: distinctStateChangesBy)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

