//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samodra Wicaksono on 04/05/23.
//

import XCTest

class RemoteFeedLoader {
     
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
