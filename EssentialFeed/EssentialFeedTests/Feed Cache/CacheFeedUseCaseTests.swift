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
    
    public func save(items: [FeedItem]) {
        store.deleteCachedCompletion { [unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    var insertion = [(items: [FeedItem], timeStamp: Date)]()
    
    private var deletionCompletion = [DeletionCompletion]()
    
    public func deleteCachedCompletion(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        deleteCachedFeedCallCount += 1
    }
    
    public func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletion[index](error)
    }
    
    public func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](nil)
    }
    
    public func insert(_ items: [FeedItem], timeStamp: Date) {
        insertion.append((items: items, timeStamp: timeStamp))
        insertCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
        
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let error = anyNSError()
        
        sut.save(items: items)
        store.completeDeletion(with: error)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestNewCacheInsertionOnSuccessDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT( currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertion.count, 1)
        XCTAssertEqual(store.insertion.first?.items, items)
        XCTAssertEqual(store.insertion.first?.timeStamp, timeStamp)
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
