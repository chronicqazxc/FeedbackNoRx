//
//  RepoSearch.swift
//  MVVMNoRx
//
//  Created by YuHan Hsiao on 2021/09/05.
//

import Foundation

typealias SearchResult = Result<[GitHubRepo], SesarchError>

enum SesarchError: Error {
    case searchFailure(String)
    case invalidURL(String?)
}

final class GitHubSearch {
    var searchType: String = "keyword"
    private var keyword: String = ""
    var urlSession: URLSessionProtocol = URLSession.shared
    var nextPageUrl: String?
    private let apiKey: String? = nil
    private var headers: [String: String]? {
//        apiKey == "your_github_access_token" ? nil : ["Authorization": "token \(apiKey)"]
        nil
    }
    private var url: URL {
        let searchKeyword = keyword.contains(" ") ? "\"\(keyword)\"" : keyword
        let searchValue = searchType == "owner" ? "user:\(searchKeyword) org:\(searchKeyword) fork:true" : "\(searchKeyword)"
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.github.com"
        urlComponents.path = "/search/repositories"
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: "\(searchValue)"),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "20"),
        ]
        return urlComponents.url!
    }
    
    init() {
        
    }
    
    func searchKeywork(_ keyword: String, completeHandler: @escaping (SearchResult)->Void) {
        self.keyword = keyword
        API.shared.get(url: self.url, headers: self.headers, session: urlSession) { data, response in
            DispatchQueue.main.async {
                if response.statusCode == 200 {
                    self.nextPageUrl = response.gitHubUserNextPage()
                    let gitHubRepos = try! JSONDecoder().decode(GitHubRepos.self, from: data)
                    completeHandler(.success(gitHubRepos.items))
                } else {
                    let messageData = try! JSONDecoder().decode(Message.self, from: data)
                    let message = messageData.errors?.first?.message ?? messageData.message
                    completeHandler(.failure(.searchFailure(message)))
                }
            }
        }
    }
    
    func getMore(completeHandler: @escaping (SearchResult)->Void) {
        guard let nextPageUrl = nextPageUrl else {
            completeHandler(.success([]))
            return
        }
        guard let url = URL(string: nextPageUrl) else {
            completeHandler(.failure(.invalidURL(nextPageUrl)))
            return
        }
        API.shared.get(url: url, headers: self.headers, session: urlSession) { data, response in
            DispatchQueue.main.async {
                if response.statusCode == 200 {
                    self.nextPageUrl = response.gitHubUserNextPage()
                    let gitHubRepos = try! JSONDecoder().decode(GitHubRepos.self, from: data)
                    completeHandler(.success(gitHubRepos.items))
                } else {
                    let messageData = try! JSONDecoder().decode(Message.self, from: data)
                    let message = messageData.errors?.first?.message ?? messageData.message
                    completeHandler(.failure(.searchFailure(message)))
                }
            }
        }
    }
}

extension URLResponse {
    func gitHubUserNextPage() -> String? {
        let link: String?
        if #available(iOS 13.0, *) {
            link = (self as! HTTPURLResponse).value(forHTTPHeaderField: "Link")
        } else {
            link = (self as! HTTPURLResponse).allHeaderFields["Link"] as? String
        }
        guard let link = link else {
            return nil
        }
        return parseLinkHeader(link)["next"]
    }
    
    func parseLinkHeader(_ linkHeader: String) -> [String: String] {
        let links = linkHeader.components(separatedBy: ",")
        var pagenates: [String: String] = [:]
        links.forEach({
            let components = $0.components(separatedBy:"; ")
            var cleanPath = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            cleanPath = cleanPath.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            let cleanKey = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "rel=\""))
            pagenates[cleanKey] = cleanPath
        })
        
        return pagenates
    }
}
