//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 04/07/23.
//

import XCTest
import EssentialFeed

final class FeedImageDataMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let data = anyData()
        let codes = [199, 201, 300, 400, 500]
        
        try codes.forEach { code in
            let response = HTTPURLResponse(statusCode: code)
            XCTAssertThrowsError(try FeedImageDataMapper.map(data, from: response))
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data()
        
        let response = HTTPURLResponse(statusCode: 200)
        XCTAssertThrowsError(try FeedImageDataMapper.map(emptyData, from: response))
    }
    
    func test_map_deliversDataOn200HTTPResponse() throws {
        let nonEmptyData = Data("non-empty data".utf8)
        
        let response = HTTPURLResponse(statusCode: 200)
        let result = try FeedImageDataMapper.map(nonEmptyData, from: response)
        
        XCTAssertEqual(result, nonEmptyData)
    }
}
