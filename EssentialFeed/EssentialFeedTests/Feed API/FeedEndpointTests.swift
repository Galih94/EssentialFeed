//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 19/07/23.
//

import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let receive: URL = FeedEndpoint.get.url(baseURL: baseURL)
        
        XCTAssertEqual(receive.scheme, "http", "scheme")
        XCTAssertEqual(receive.host(), "base-url.com", "host")
        XCTAssertEqual(receive.path(), "/v1/feed", "path")
        XCTAssertEqual(receive.query(), "limit=10", "query")
        
    }
}
