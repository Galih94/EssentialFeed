//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 13/05/23.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedCompletion { [unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([FeedItem], Date)
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
    
    public func insert(_ items: [FeedItem], timeStamp: Date, completion: @escaping InsertionCompletion) {
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
        
        sut.save(items: items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timeStamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let timeStamp = Date()
        let (sut, store) = makeSUT( currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        let error = anyNSError()
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(items: items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: error)
        
        XCTAssertEqual(receivedError as? NSError, error)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_save_failsOnInsertionError() {
        let timeStamp = Date()
        let (sut, store) = makeSUT( currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        let insertionError = anyNSError()
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(items: items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        
        XCTAssertEqual(receivedError as? NSError, insertionError)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_save_successOnSuccessfulCacheInsertion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT( currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(items: items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        
        XCTAssertNil(receivedError)
        wait(for: [exp], timeout: 1.0)
    }
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
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
