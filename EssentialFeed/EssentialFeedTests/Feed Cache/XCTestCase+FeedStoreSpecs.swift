//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 19/05/23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        var deletionError: Error?
        
        let exp = expectation(description: "Waiting for deletion")
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
        return deletionError
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timeStamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timeStamp: cache.timeStamp){ receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        
        return insertionError
    }
    
    func expect(_ sut: FeedStore, toRetriveTwice expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrive expectedResult: RetrievedCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for retrieval")
        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (
                .found(resultFeed, timeStampFeed),
                .found(expectedResultFeed, expectedResultTimeStamp)):
                
                XCTAssertEqual(resultFeed, expectedResultFeed, file: file, line: line)
                XCTAssertEqual(timeStampFeed, expectedResultTimeStamp, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
}
