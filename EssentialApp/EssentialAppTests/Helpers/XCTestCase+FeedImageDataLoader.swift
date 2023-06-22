//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 22/06/23.
//

import XCTest
import EssentialFeed

protocol FeedImageDataLoaderTestCase: XCTestCase {}

extension FeedImageDataLoaderTestCase {
    
    func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for loadImageData completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let ( .success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure, .failure): break
            default: XCTFail("Expected \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
