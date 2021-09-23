//
//  ViewModelProtocol.swift
//  MVVMNoRx
//
//  Created by YuHan Hsiao on 2021/09/20.
//

import Foundation
import UIKit.UIImage
import Feedback

enum State {
    case idle
    case loading
    case searchError(String)
    case reload([RepoCellViewModel])
}

enum Event {
    // UI generate
    case search(String)
    case configureCellAtIndexPath(IndexPath)
    case beginDragging
    case didEndDragging([IndexPath])
    case didEndDecelerating([IndexPath])
    case scrollReachBottom
    // Side effect generate
    case empty
    case loaded([RepoCellViewModel])
    case error(String)
    case loading
}

protocol InputProtocol {
    var event: Dynamic<Event> { get }
    func send(_ event: Event)
}

protocol OutputProtocol {
    var state: Dynamic<State> { get }
}

protocol ListViewModelProtocol {
    var input: InputProtocol { get }
    var output: OutputProtocol { get }
}

protocol RepoCellViewModel {
    var avatarUrl: String { get }
    var fullName: String { get }
    var stargazersCount: Int { get }
    var license: License? { get }
    var language: String? { get }
    var description: String? { get }
    var avatarImage: UIImage? { get }
    var url: String { get }
}
