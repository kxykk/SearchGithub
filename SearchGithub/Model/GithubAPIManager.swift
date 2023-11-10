//
//  NetworkManger.swift
//  SearchGithub
//
//  Created by 康 on 2023/10/29.
//

import UIKit
import RxSwift

typealias DoneHandler = (Result<GithubApiResponse, AFError>) -> Void
typealias completionHandler = (Data?, URLResponse?, Error?) -> Void

class GithubAPIManager {
    static let shared = GithubAPIManager()
    init() {}
    
    static let baseURL = "https://api.github.com/search/repositories"
    var urlSession = URLSession.shared
    private var result: [Repository] = []
    
    func doGet(urlString: String) -> Observable<Data> {
        return Observable.create { [weak self] observer in
            guard let url = URL(string: urlString) else {
                observer.onError(AFError.invalidURL)
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = self?.urlSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    observer.onNext(data)
                    observer.onCompleted()
                } else {
                    observer.onError(AFError.noData)
                }
            }
            task?.resume()
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }

}

// Response Data
struct GithubApiResponse: Decodable {
    let items: [Repository]
}

struct Repository: Decodable {
    let name: String
    let full_name: String
    let description: String?
    let owner: Owner
    let language: String?
    let watchers_count: Int
    let stargazers_count: Int
    let forks_count: Int
    let open_issues_count: Int
}

struct Owner: Decodable{
    let login: String
    let avatar_url: String?
}

enum AFError: Error {
    case invalidURL
    case noData
    case jsonParseFailed
}

enum HTTPStatusCode: Int {
    case ok = 200
    case notModified = 304
    case unprocessableEntity = 422
    case serviceUnavailable = 503
    case unknown
    
    init(_ rawValue: Int) {
        self = HTTPStatusCode(rawValue: rawValue) ?? .unknown
    }
    
    var correspondingError: NSError {
        switch self {
        case .ok:
            return NSError(domain: "", code: 200, userInfo: nil)
        case .notModified:
            return NSError(domain: "RequestError", code: 304, userInfo: [NSLocalizedDescriptionKey: "Not modified"])
        case .unprocessableEntity:
            return NSError(domain: "RequestError", code: 422, userInfo: [NSLocalizedDescriptionKey: "Validation failed, or the endpoint has been spammed."])
        case .serviceUnavailable:
            return NSError(domain: "RequestError", code: 503, userInfo: [NSLocalizedDescriptionKey: "Service unavailable"])
        case .unknown:
            return NSError(domain: "RequestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown status code"])
        }
    }
}


