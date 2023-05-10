//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Galih Samodra Wicaksono on 10/05/23.
//

import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETFeedResult_matchedFixedTestAccountData() {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let sut = RemoteFeedLoader(url: testServerURL, client: client)
        
        var receivedResult: LoadFeedResult?
        let exp = expectation(description: "Waiting for load")
        sut.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 20.0)
        switch receivedResult {
        case let .success(items):
            XCTAssertEqual(items.count, 8)
        case let .failure(error):
            XCTFail("Expected succcess got \(error) instead")
        default:
            XCTFail("Expected succcess got nil instead")
        }
    }

}
