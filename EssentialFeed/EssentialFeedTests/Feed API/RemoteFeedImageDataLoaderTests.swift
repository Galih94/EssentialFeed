//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 14/06/23.
//

import XCTest
import EssentialFeed

public final class RemoteFeedImageDataLoader {
    init(client: Any) {}
    
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    // MARK: - Helpers
    private class HTTPClientSpy {
        var requestedURLs = [URL]()
    }
}
