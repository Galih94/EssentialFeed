//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samodra Wicaksono on 09/05/23.
//

import XCTest

//MARK: - Production code move later
final class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) {_, _,_ in
            
        }.resume()
    }
}


//MARK: - Tests code
final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(with: url, for: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    //MARK: - Helper Tests code
    
    private final class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()
        override init(){}
        
        func stub(with url: URL, for task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            let dataTask = FakeURLSessionDataTask()
            return stubs[url] ?? dataTask
        }
    }
    
    private final class FakeURLSessionDataTask: URLSessionDataTask {
        override init(){}
        
        override func resume() {}
    }
    
    private final class URLSessionDataTaskSpy: URLSessionDataTask {
        override init(){}
        
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }

}
