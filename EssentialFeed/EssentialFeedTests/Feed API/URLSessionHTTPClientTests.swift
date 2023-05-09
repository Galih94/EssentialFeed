//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samodra Wicaksono on 09/05/23.
//

import XCTest
import EssentialFeed

//MARK: - Production code move later
protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}

final class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
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
    
    func test_getFromURL_failsDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "any error domain", code: 1)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Wait for get from url")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error) got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    //MARK: - Helper Tests code
    
    private final class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool { // need to override canInit to make sure we are the one who set the request return success or fails
            guard let url = request.url else { return false } // make sure url is not nil
            
            return URLProtocolStub.stubs[url] != nil // return true if url is exist in stubs, at this point if return false URLProtocolStub will not initialized
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request // make sure we do not change URLRequest on URLProtocolStub
        }
        
        override func startLoading() {
            guard let url = request.url, // get url from property request of URLProtocol
                  let stub = URLProtocolStub.stubs[url] // make sure url founc in stubs
            else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error) // stub our error into URLProtocol if exist
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }

}
