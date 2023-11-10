//
//  MainViewModel.swift
//  SearchGithub
//
//  Created by 康 on 2023/10/29.
//

import UIKit
import RxSwift


typealias DownloadHandler = (Result<UIImage, Error>) -> Void

class MainViewModel {
    
    private(set) var repositories: GithubApiResponse?
    private(set) var errorMessage: String?
    var imageCache: [String: UIImage] = [:]
    let disposeBag = DisposeBag()
    
    var repositoriesObservable: Observable<GithubApiResponse?> {
        return repositoriesSubject.asObservable()
    }
    private let repositoriesSubject = BehaviorSubject<GithubApiResponse?>(value: nil)
    
    var dataDidUpdate: (() -> Void)?
    let manager = GithubAPIManager.self
    
    func searchRepo(query: String) {
        let query = "?q=\(query)"
        let finalURL = manager.baseURL + query
        manager.shared.doGet(urlString: finalURL)
            .subscribe { [weak self] data in
                guard let result = try? JSONDecoder().decode(GithubApiResponse.self, from: data) else {
                    return
                }
                self?.setRepositories(response: result)
            }.disposed(by: disposeBag)
    }
    
    func downloadImage(urlString: String) -> Observable<UIImage> {
        if let cachedImage = imageCache[urlString] {
            return Observable.just(cachedImage)
        }
        
        return manager.shared.doGet(urlString: urlString)
            .flatMap { data -> Observable<UIImage> in
                guard let image = UIImage(data: data) else {
                    throw AFError.noData
                }
                self.imageCache[urlString] = image
                return Observable.just(image)
            }
    }
    
    func setRepositories(response: GithubApiResponse) {
        self.repositories = response
        self.repositoriesSubject.onNext(response)
    }
}

