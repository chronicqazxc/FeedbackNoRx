//
//  ViewController.swift
//  MVVMNoRx
//
//  Created by YuHan Hsiao on 2021/09/04.
//

import UIKit
import SafariServices

class GitHubRepoListViewController: UIViewController {
    
    let listViewModel: ListViewModelProtocol = GitHubRepoListViewModel()
    var cellViewModels: [RepoCellViewModel] = [GitHubRepoCellViewModel]()
    
    var searchView: GitHubRepoSearchView {
        get {
            view as! GitHubRepoSearchView
        }
    }
    
    override func loadView() {
        super.loadView()
        view = GitHubRepoSearchView(frame: .zero)
        searchView.tableView.dataSource = self
        searchView.tableView.delegate = self
        searchView.searchBar.delegate = self
        searchView.tableView.separatorStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindding()
    }

    func bindding() {
        listViewModel.output.state.bind { [unowned self] state in
            DispatchQueue.main.async {
                switch state {
                case .idle:
                    searchView.showMessage("")
                case .loading:
                    searchView.showMessage("loading")
                case .searchError(let message):
                    searchView.showMessage(message)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.searchView.hideMessage()
                    }
                case .reload(let cellViewModels):
                    searchView.tableView.separatorStyle = .singleLine
                    searchView.hideMessage()
                    self.cellViewModels = cellViewModels
                    searchView.tableView.reloadData()
                }
            }
        }
    }
}

extension GitHubRepoListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == cellViewModels.count {
            self.listViewModel.input.send(.scrollReachBottom)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? GitHubRepoCell else {
            fatalError("GitHubRepoCell dose not exist.")
        }
        if !tableView.isDragging && !tableView.isDecelerating {
            listViewModel.input.send(.configureCellAtIndexPath(indexPath))
        }
        cell.viewModel = cellViewModels[indexPath.row]
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchView.searchBar.resignFirstResponder()
        listViewModel.input.send(.beginDragging)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if let pathes = searchView.tableView.indexPathsForVisibleRows {
                listViewModel.input.send(.didEndDragging(pathes))
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let pathes = searchView.tableView.indexPathsForVisibleRows {
            listViewModel.input.send(.didEndDecelerating(pathes))
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = cellViewModels[indexPath.row]
        let webView = SFSafariViewController(url: URL(string: data.url)!)
        present(webView, animated: true, completion: nil)
    }
}

extension GitHubRepoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        listViewModel.input.send(.search(searchBar.text!))
        searchView.searchBar.resignFirstResponder()
    }
}
