//
//  FeedbackTests.swift
//  FeedbackTests
//
//  Created by YuHan Hsiao on 2021/09/20.
//

import XCTest
@testable import Feedback

enum State {
    case idle
    case loading
    case loaded(Int)
    case error(Error)
}

enum Event {
    case onAppear
    case increase
    case loaded(Int)
}

class FeedbackTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDynamic() throws {
        let dynamic = Dynamic<String>("")
        dynamic.bind { newValue in
            XCTAssertNotEqual(newValue, "124")
            XCTAssertEqual(newValue, "123")
        }
        dynamic.value = "123"
    }
    
    var loadedValue: Int = 0
    
    func testSystem() {
        let exp = XCTestExpectation()
        
        let system = System(initial: (State.idle, Event.onAppear),
                            reduce: reduce,
                            feedbacks: feedbackWith)

        system.state.bindAndFire { newState in
            if case let .loaded(newValue) = newState {
                exp.fulfill()
                XCTAssertEqual(1, newValue)
            }
        }
        
        system.event.value = .increase
        
        wait(for: [exp], timeout: 3.0)
    }
    
    func feedbackWith(input: Event) -> Feedback<State, Event> {
        Feedback<State, Event> { state, callback in
            if case .increase = input {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.loadedValue += 1
                    return callback(Event.loaded(self.loadedValue))
                }
            }
            return callback(input)
        }
    }
    
    func reduce(state: State, event: Event) -> State {
        switch event {
        case .loaded(let value):
            return .loaded(value)
        default:
            break
        }
        return state
    }
}
