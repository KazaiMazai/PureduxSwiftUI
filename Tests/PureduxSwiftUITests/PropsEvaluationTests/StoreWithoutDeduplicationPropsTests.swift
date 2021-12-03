//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2021.
//

import XCTest
@testable import PureduxSwiftUI
import SwiftUI
import PureduxStore
import PureduxCommon
import UIKit


class ViewEnvStoreWithoutDeduplicationPropsTests: ViewWithStoreWithoutDeduplicationPropsTests {
    @discardableResult override func setupWindowForTests(
        propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: StoreProvidingView(store: store) {
                Text.with(
                    removeStateDuplicates: .neverEqual,
                    props: { (state: TestAppState, store: AnyPublishingStore<TestAppState, Action>) -> String in
                        propsEvaluatedExpectation.fulfill()
                        return state.subStateWithTitle.title
                    },
                    content: {
                        Text($0)
                    }
                )
            }
        )
    }
}

class ViewWithStoreWithoutDeduplicationPropsTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var store: RootEnvStore = {
        RootEnvStore(
            store: Store<TestAppState, Action>(initial: state) { state, action in
                state.reduce(action)
            }
        )
    }()

    @discardableResult func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: Text.with(
                store: store.eraseToAnyStore(),
                removeStateDuplicates: .neverEqual,
                props: { (state, store) -> String in
                    propsEvaluatedExpectation.fulfill()
                    return state.subStateWithTitle.title
                },
                content: {
                    Text($0)
                }
            )
        )
    }
}

extension ViewWithStoreWithoutDeduplicationPropsTests {

    func test_WhenNoActionAfterSetup_ThenPropsNotEvaluated() {
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForEveryAction() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForEveryAction() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }
}

extension ViewWithStoreWithoutDeduplicationPropsTests {

    static var allTests = [
        ("test_WhenNoActionAfterSetup_ThenPropsNotEvaluated",
         test_WhenNoActionAfterSetup_ThenPropsNotEvaluated),

        ("test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForEveryAction",
         test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForEveryAction),

        ("test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForEveryAction",
         test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForEveryAction)
    ]
}

