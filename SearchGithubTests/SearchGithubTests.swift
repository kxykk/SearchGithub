//
//  SearchGithubTests.swift
//  SearchGithubTests
//
//  Created by 康 on 2023/11/9.
//

import XCTest
@testable import SearchGithub

class SearchGithubTests: XCTestCase {
    
    var githubAPIManager: GithubAPIManager!
    var mockURLSession: MockURLSession!
    
    // 會在每一個測試前被呼叫
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        githubAPIManager = GithubAPIManager()
        githubAPIManager.urlSession = mockURLSession
    }
    // 會在每一個測試結束後被呼叫
    override func tearDown() {
        githubAPIManager = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // 測試在API呼叫成功的時候，是否返回了正確的數據
    func testDoGetSuccessReturnsRepos() {
        
        // 期望情況
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // 如果url不對，就標記為Fail
        guard let url = URL(string: GithubAPIManager.baseURL) else {
            XCTFail("URL cannot be created")
            return
        }
        // 做一個空的JSON回傳值
        let data = "{}".data(using: .utf8)
        // 模擬一個ok(回傳200)的情況
        let urlResponse = HTTPURLResponse(url: url, statusCode: HTTPStatusCode.ok.rawValue, httpVersion: nil, headerFields: nil)
        mockURLSession.completionHandlerToReturn = (data, urlResponse, nil)
        
        _ = githubAPIManager.doGet(urlString: GithubAPIManager.baseURL).subscribe(
            onNext: { data in
                statusCode = (urlResponse?.statusCode)
                promise.fulfill()
            },
            onError: { error in
                responseError = error
                promise.fulfill()
            }
        )
        
        wait(for: [promise], timeout: 5)
        
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, HTTPStatusCode.ok.rawValue)
    }
    
    // 測試API返回失敗的時候，是否返回正確的錯誤值
    func testDoGetFailureReturnsError() {
        let promise = expectation(description: "Completion handler invoked")
        var responseError: Error?
        
        mockURLSession.completionHandlerToReturn = (nil, nil, AFError.noData)
        
        _ = githubAPIManager.doGet(urlString: GithubAPIManager.baseURL).subscribe(
            onNext: { _ in
                XCTFail("Should not succeed")
            },
            onError: { error in
                responseError = error
                promise.fulfill()
            }
        )
        
        wait(for: [promise], timeout: 5)
        
        XCTAssertNotNil(responseError)
    }
    
    func testDoGetSuccessDecodesProperly() {
        // 設定期望值
        let promise = expectation(description: "Completion handler invoked")
        var responseRepos: [Repository]?
        var responseError: Error?

        // 模擬一個 JSON 字符串
        let jsonString = """
        {
            "items": [
                {
                    "name": "repo1",
                    "full_name": "user/repo1",
                    "description": "A test repo",
                    "owner": {
                        "login": "user",
                        "avatar_url": "http://example.com/avatar.png"
                    },
                    "language": "Swift",
                    "watchers_count": 100,
                    "stargazers_count": 150,
                    "forks_count": 50,
                    "open_issues_count": 5
                }
            ]
        }
        """
        let data = jsonString.data(using: .utf8)

        // 創建模擬回應
        guard let url = URL(string: GithubAPIManager.baseURL) else {
            XCTFail("URL cannot be created")
            return
        }
        let urlResponse = HTTPURLResponse(url: url, statusCode: HTTPStatusCode.ok.rawValue, httpVersion: nil, headerFields: nil)
        mockURLSession.completionHandlerToReturn = (data, urlResponse, nil)

        // 測試 doGet 方法
        _ = githubAPIManager.doGet(urlString: GithubAPIManager.baseURL).subscribe(
            onNext: { data in
                do {
                    // 嘗試解碼數據
                    let decodedResponse = try JSONDecoder().decode(GithubApiResponse.self, from: data)
                    responseRepos = decodedResponse.items
                    promise.fulfill()
                } catch {
                    XCTFail("Decoding failed: \(error)")
                }
            },
            onError: { error in
                responseError = error
                promise.fulfill()
            }
        )

        // 等待期望值
        wait(for: [promise], timeout: 5)

        // 檢查結果
        XCTAssertNil(responseError)
        XCTAssertNotNil(responseRepos)
        XCTAssertEqual(responseRepos?.first?.name, "repo1")
        XCTAssertEqual(responseRepos?.first?.owner.login, "user")
    }

}



class MockURLSession: URLSession {
    
    var completionHandlerToReturn: (data: Data?, urlResponse: URLResponse?, error: Error?)?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping completionHandler) -> URLSessionDataTask {
        let data = completionHandlerToReturn?.data
        let response = completionHandlerToReturn?.urlResponse
        let error = completionHandlerToReturn?.error
        return MockURLSessionDataTask {
            completionHandler(data, response, error)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    
    private let closure: () -> Void
    var isCancelled = false
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        if !isCancelled {
            closure()
        }
    }
    
    override func cancel() {
        isCancelled = true
    }
}

