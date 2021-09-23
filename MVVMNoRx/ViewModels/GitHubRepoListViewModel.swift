//
//  ViewModel.swift
//  MVVMNoRx
//
//  Created by YuHan Hsiao on 2021/09/04.
//

import Foundation
import Combine
import Feedback

final class GitHubRepoListViewModel: ListViewModelProtocol {
    
    /// Icon downloader helper
    fileprivate var iconDownloader = PendingIconDownloaderOperations()
    
    /// Data
    fileprivate var repos = [GitHubRepo]()
    
    /// Restrice UI generate new event via input parameter
    let input: InputProtocol = Input.init()
    
    /// Restrice UI monitor state change via output
    let output: OutputProtocol = Output.init()
    
    /// GitHub repo search helper
    private let githubSearch = GitHubSearch()
    
    init() {
        let system = System<State, Event>(initial: (State.idle, Event.empty),
                                          reduce: reduce,
                                          feedbacks: feedback)
        // Bind state change to output
        system.state.bindAndFire { newState in
            // Notify UI whenever new state generated
            self.output.state.value = newState
        }
        
        // Bind input to state machine
        input.event.bind { input in
            // Feedbacks will invoked when new event occur
            system.event.value = input
        }
    }
    
    /// Side effect occur, e.g. Fetch data from network
    /// - Parameter input: Event provided by UI
    /// - Returns: New event after side effect
    fileprivate func feedback(input: Event) -> Feedback<State, Event> {
        Feedback<State, Event> { state, callback  in
            switch input {
                // Search keywork
            case .search(let text):
                callback(.loading)
                self.githubSearch.searchKeywork(text) { result in
                    switch result {
                    case .success(let repos):
                        self.repos = repos
                        self.iconDownloader = .init(downloaders: repos.map {
                            AppIconDownloader(url: $0.owner.avatar_url)
                        })
                        
                        callback(.loaded(repos.map {
                            return GitHubRepoCellViewModel(avatarUrl: $0.owner.avatar_url, fullName: $0.full_name, stargazersCount: $0.stargazers_count, license: $0.license, language: $0.language, description: $0.description, url: $0.html_url)
                        }))
                    case .failure(let error):
                        guard case let .searchFailure(message) = error else {
                            fatalError()
                        }
                        callback(.error(message))
                    }
                }
                // Load image when cell appear
            case .configureCellAtIndexPath(let indexPath):
                let appIconDownloader = self.iconDownloader[indexPath.row]
                if case .new = appIconDownloader.iconDownloadStatus {
                    self.iconDownloader.startDownload(for: appIconDownloader, at: indexPath) { [unowned self] in
                        if $0 == .finished {
                            let cellViewModels = repos.enumerated().map { (index, repo) -> GitHubRepoCellViewModel in
                                let downloadTask = self.iconDownloader[index]
                                return GitHubRepoCellViewModel(avatarUrl: repo.owner.avatar_url, fullName: repo.full_name, stargazersCount: repo.stargazers_count, license: repo.license, language: repo.language, description: repo.description, avatarImage: downloadTask.image, url: repo.html_url)
                            }
                            callback(.loaded(cellViewModels))
                        }
                    }
                    
                }
                // Stop download image when table view scrolling
            case .beginDragging:
                self.iconDownloader.suspendAllOperations()
                // Start download image for visible cells when table view stop scroll
            case .didEndDecelerating(let pathes),
                    .didEndDragging(let pathes):
                self.iconDownloader.loadImagesForOnScreenCells(indexPathsForVisibleRows: pathes) { [unowned self] repose in
                    let cellViewModels = repos.enumerated().map { (index, repo) -> GitHubRepoCellViewModel in
                        let downloadTask = self.iconDownloader[index]
                        return GitHubRepoCellViewModel(avatarUrl: repo.owner.avatar_url, fullName: repo.full_name, stargazersCount: repo.stargazers_count, license: repo.license, language: repo.language, description: repo.description, avatarImage: downloadTask.image, url: repo.html_url)
                    }
                    callback(.loaded(cellViewModels))
                }
                self.iconDownloader.resumeAllOperations()
                // Fetch next page of data when table view scroll to the bottom
            case .scrollReachBottom:
                if case .loading = state {
                    callback(input)
                    return
                }
                callback(.loading)
                self.githubSearch.getMore { result in
                    switch result {
                    case .success(let repos):
                        if repos.isEmpty {
                            callback(.empty)
                            return
                        }
                        self.repos += repos
                        self.iconDownloader.append(repos.map { AppIconDownloader(url: $0.owner.avatar_url) })
                        callback(.loaded(self.repos.map {
                            return GitHubRepoCellViewModel(avatarUrl: $0.owner.avatar_url, fullName: $0.full_name, stargazersCount: $0.stargazers_count, license: $0.license, language: $0.language, description: $0.description, url: $0.html_url)
                        }))
                    case .failure(let error):
                        guard case let .searchFailure(message) = error else {
                            fatalError()
                        }
                        callback(.error(message))
                    }
                }
            default:
                callback(.empty)
            }
        }
    }
    
    /// Generate new state
    /// - Parameters:
    ///   - state: UI state
    ///   - event: System event
    /// - Returns: New state
    fileprivate func reduce(state: State, event: Event) -> State {
        switch event {
        case .loading:
            return .loading
        case .loaded(let value):
            return .reload(value)
        case .empty:
            return .idle
        case .error(let errorDesc):
            return .searchError(errorDesc)
        default:
            break
        }
        return state
    }
}

extension GitHubRepoListViewModel {
    
    fileprivate class Input: InputProtocol {
        var event: Dynamic<Event> = .init(.empty)
        func send(_ event: Event) {
            self.event.value = event
        }
    }
    
    fileprivate class Output: OutputProtocol {
        var state: Dynamic<State> = .init(.idle)
    }
}
