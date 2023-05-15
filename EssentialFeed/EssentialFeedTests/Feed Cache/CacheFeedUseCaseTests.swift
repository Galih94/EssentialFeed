//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 13/05/23.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
        
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let error = anyNSError()
        
        sut.save(items: items) { _ in }
        store.completeDeletion(with: error)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT( currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        let localItems = items.map {
            LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)
        }
        
        sut.save(items: items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(localItems, timeStamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_successOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDelitionErrorsAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(items: [uniqueItem()]) {
            receivedResults.append($0)
        }
        
        sut = nil
        
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
        
        
    }
    
    func test_save_doesNotDeliverInsertionErrorsAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult?]()
        sut?.save(items: [uniqueItem()]) {
            receivedResults.append($0)
        }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
        
        
    }
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var receivedError: Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(items: [uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        
        XCTAssertEqual(receivedError as? NSError, expectedError, file: file, line: line)
        wait(for: [exp], timeout: 1.0)
    }
    
    private class FeedStoreSpy: FeedStore {
        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void
        
        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([LocalFeedItem], Date)
        }
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        private var deletionCompletion = [DeletionCompletion]()
        private var insertionCompletion = [InsertionCompletion]()
        
        public func deleteCachedCompletion(completion: @escaping DeletionCompletion) {
            deletionCompletion.append(completion)
            receivedMessages.append(.deleteCacheFeed)
        }
        
        public func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletion[index](error)
        }
        
        public func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletion[index](nil)
        }
        
        public func insert(_ items: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletion.append(completion)
            receivedMessages.append(.insert(items, timeStamp))
        }
        
        public func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletion[index](error)
        }
        
        public func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletion[index](nil)
        }
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(),
                        description: "any",
                        location: "any",
                        imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error domain", code: 1)
    }

}
