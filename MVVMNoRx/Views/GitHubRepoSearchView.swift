//
//  SubmitView.swift
//  MVVMNoRx
//
//  Created by YuHan Hsiao on 2021/09/04.
//

import UIKit

class GitHubRepoSearchView: UIView {

    let searchBar = UISearchBar(frame: .zero)
    let tableView = UITableView(frame: .zero)
    let messageLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        tableView.register(GitHubRepoCell.self, forCellReuseIdentifier: "cell")
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        addSubview(searchBar)
        addSubview(tableView)
        addSubview(messageLabel)
        
        searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
    }
    
    func showMessage(_ message: String) {
        messageLabel.backgroundColor = UIColor(white: 1, alpha: 0.9)
        messageLabel.text = message
    }
    
    func hideMessage() {
        messageLabel.backgroundColor = UIColor(white: 1, alpha: 0.0)
        messageLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
