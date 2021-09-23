//
//  MVVMNoRxTests.swift
//  MVVMNoRxTests
//
//  Created by YuHan Hsiao on 2021/09/05.
//

import XCTest
@testable import MVVMNoRx

class MVVMNoRxTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDemo() {
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 2
        exp.assertForOverFulfill = true
        let viewModel = GitHubRepoListViewModel()
        viewModel.output.state.bind { state in
            switch state {
            case .loading:
                exp.fulfill()
            case .reload(_):
                exp.fulfill()
            case .searchError(_):
                break
            case .idle:
                break
            }
        }
        viewModel.input.event.value = .search("apple")
        wait(for: [exp], timeout: 3.0)
    }

}
