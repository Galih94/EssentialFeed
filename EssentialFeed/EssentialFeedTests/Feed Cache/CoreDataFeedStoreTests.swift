//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 19/05/23.
//

import XCTest
import EssentialFeed

final class CoreDataFeedStore: FeedStore {
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
}

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
    }
    
    func test_insert_overridePreviouslyInsertedCacheValues() {
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
    }
    
    func test_storeSideEffects_runSerially() {
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

}
