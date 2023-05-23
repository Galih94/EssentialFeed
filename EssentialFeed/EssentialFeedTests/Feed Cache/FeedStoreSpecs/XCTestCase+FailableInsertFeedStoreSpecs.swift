//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 19/05/23.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let date = Date()
        
        let insertionError = insert((feed, date), to: sut)
        
        XCTAssertNotNil(insertionError, "Expect insert failure")
    }
    
    func assertThatInsertHasNoSideEffectOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let date = Date()
        
        insert((feed, date), to: sut)
        
        expect(sut, toRetrive: .success(.empty))
    }
}
