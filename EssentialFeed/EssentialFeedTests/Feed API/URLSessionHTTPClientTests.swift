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
            
        }
    }
}


//MARK: - Tests code
final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_createDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURL, [url])
    }
    
    //MARK: - Helper Tests code
    
    private final class URLSessionSpy: URLSession {
        var receivedURL = [URL]()
        
        override init(){}
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURL.append(url)
            let dataTask = FakeURLSessionDataTask()
            return dataTask
        }
    }
    
    private final class FakeURLSessionDataTask: URLSessionDataTask {
        override init(){}
    }

}
