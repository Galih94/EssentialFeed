//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samodra Wicaksono on 04/05/23.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    init (url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = makeSUT(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = makeSUT(url: url,client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, client: HTTPClient) -> RemoteFeedLoader {
        return RemoteFeedLoader(url: url , client: client)
    }

}
