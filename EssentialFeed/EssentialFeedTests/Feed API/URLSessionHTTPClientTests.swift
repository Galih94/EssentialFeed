//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samodra Wicaksono on 09/05/23.
//

import XCTest
import EssentialFeed

//MARK: - Production code move later
final class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void ) {
        session.dataTask(with: url) {_, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}


//MARK: - Tests code
final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests() // make sure we use URLProtocolStub here
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error domain", code: 1)
        URLProtocolStub.stub(url: url, data: nil, response: nil,  error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for get from url")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error) got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests() // make sure we unregister when done
    }
    
    //MARK: - Helper Tests code
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }

        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
                
        override class func canInit(with request: URLRequest) -> Bool { // need to override canInit to make sure we are the one who set the request return success or fails
            guard let url = request.url else { return false } // make sure url is not nil
            return URLProtocolStub.stubs[url] != nil // return true if url is exist in stubs, at this point if return false URLProtocolStub will not initialized
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request // make sure we do not change URLRequest on URLProtocolStub
        }
        
        override func startLoading() {
            // get url from property request of URLProtocol and make sure url founc in stubs
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error) // stub our error into URLProtocol if exist
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }

}
