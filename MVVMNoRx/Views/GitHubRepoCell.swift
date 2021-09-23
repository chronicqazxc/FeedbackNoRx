//
//  GitHubRepoCell.swift
//  MVVMNoRx
//
//  Created by YuHan Hsiao on 2021/09/05.
//

import UIKit

class GitHubRepoCell: UITableViewCell {
    
    var viewModel: RepoCellViewModel! {
        didSet {
            githubView.title.text = viewModel.fullName
            githubView.descriptionLabel.text = viewModel.description
            githubView.startLabel.text = "⭐️ \(viewModel.stargazersCount)"
            githubView.languageLabel.text = "📖 \(viewModel.language ?? "")"
            githubView.avatarImageView.image = viewModel.avatarImage
        }
    }
    
    var avatarImage: UIImage? {
        didSet {
            githubView.avatarImageView.image = avatarImage
        }
    }
    
    private let githubView = GitHubListView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        githubView.toAutoLayout()
        
        addSubview(githubView)

        githubView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        githubView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        githubView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        githubView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        githubView.avatarImageView.image = nil
    }
}

class GitHubListView: UIView {
    
    let title = UILabel(frame: .zero)
    let descriptionLabel = UILabel(frame: .zero)
    let startLabel = UILabel(frame: .zero)
    let languageLabel = UILabel(frame: .zero)
    let avatarImageView = UIImageView(frame: .zero)
    let vStackView = UIStackView(frame: .zero)
    let hStackView = UIStackView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    func setupUI() {
        
        vStackView.axis = .vertical
        vStackView.spacing = 10
        descriptionLabel.numberOfLines = 0
        title.textAlignment = .center
        title.font = .boldSystemFont(ofSize: 20)
        
        vStackView.toAutoLayout()
        descriptionLabel.toAutoLayout()
        
        addSubview(vStackView)
        
        vStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        vStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        vStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        vStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
        vStackView.addArrangedSubview(title)
        
        setupHStack()
        vStackView.addArrangedSubview(hStackView)
        
        vStackView.addArrangedSubview(descriptionLabel)
    }
    
    func setupHStack() {
        hStackView.axis = .horizontal
        hStackView.spacing = 5
        hStackView.toAutoLayout()
        
        startLabel.toAutoLayout()
        languageLabel.toAutoLayout()
        avatarImageView.toAutoLayout()
        
        let vStackView = UIStackView(frame: .zero)
        vStackView.axis = .vertical
        vStackView.toAutoLayout()
        vStackView.addArrangedSubview(startLabel)
        vStackView.addArrangedSubview(languageLabel)
        
        hStackView.addArrangedSubview(avatarImageView)
        avatarImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        hStackView.addArrangedSubview(vStackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    func toAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}
