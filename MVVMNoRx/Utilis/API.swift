//
//  API.swift
//  GitHubRepoSearch
//
//  Created by YuHan Hsiao on 2021/07/06.
//

import Foundation

typealias APICallback = (Data, HTTPURLResponse) -> Void
typealias DataTaskCompletionHandler = (Data?, URLResponse?, Error?) -> Void
protocol URLSessionProtocol {
  func dataTask(
    with request: URLRequest,
    completionHandler: @escaping DataTaskCompletionHandler
  ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol { }

final class API {
    static let shared = API()
    
    private var task: URLSessionDataTask?
    
    func get(url: URL,
             headers: [String: String]? = nil,
             session: URLSessionProtocol = URLSession.shared,
             completion: APICallback?) {
        task?.cancel()
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        task = session.dataTask(with: request) { (data, response, error) in
            if let data = data, let response = response {
                completion?(data, response as! HTTPURLResponse)
            }
        }
        task!.resume()
    }
}
