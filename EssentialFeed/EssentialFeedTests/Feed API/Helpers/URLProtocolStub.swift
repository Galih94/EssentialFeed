//
//  URLProtocolStub.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 15/06/23.
//

import Foundation

final class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { return queue.sync { _stub }}
        set { queue.sync { _stub = newValue }}
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
    }

    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
    }
            
    override class func canInit(with request: URLRequest) -> Bool { // need to override canInit to make sure we are the one who set the request return success or fails
        return true // set always true so it willalways be initalized regardless of url
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request // make sure we do not change URLRequest on URLProtocolStub
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error) // stub our error into URLProtocol if exist
        }
        stub.requestObserver?(request)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    static func removeStub() {
        stub = nil
    }
}
