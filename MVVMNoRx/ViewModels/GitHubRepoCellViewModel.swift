//
//  GitHubRepoCellViewModel.swift
//  MVVMNoRx
//
//  Created by YuHan Hsiao on 2021/09/05.
//

import UIKit

struct GitHubRepoCellViewModel: RepoCellViewModel {
    let avatarUrl: String
    let fullName: String
    let stargazersCount: Int
    let license: License?
    let language: String?
    let description: String?
    var avatarImage: UIImage?
    let url: String
}
