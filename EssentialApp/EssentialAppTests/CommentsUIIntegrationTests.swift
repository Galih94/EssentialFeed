//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 10/07/23.
//

import XCTest
import Combine
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected a third loading request once user initiates another load" )
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiated reload")
        
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading completes with error")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let(sut, loader) = makeSUT()
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [ImageComment]())
        
        loader.completeCommentsLoading(with: [comment0])
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
        
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let(sut, loader) = makeSUT()
        let comment0 = makeComment()
        
        sut.loadViewIfNeeded()
        
        loader.completeCommentsLoading(with: [comment0])
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComment]())
    }
    
    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment0 = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment0])
        
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_loadFeedCompletion_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ListViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
        
    }
    
    private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
        return ImageComment(
            id: UUID(),
            message: message,
            createdAt: Date(),
            username: username)
    }
    
    private class LoaderSpy {
        private var requests = [PassthroughSubject<[ImageComment], Error>]()
        var loadCommentsCallCount: Int {
            return requests.count
        }
        
        public func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any domain", code: 1)
            requests[index].send(completion: .failure(error))
        }
        
    }
    
    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
        let viewModel = ImageCommentsPresenter.map(comments)
        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.messsage, "message at \(index) failed, expected \(comment.messsage), found \(String(describing: sut.commentMessage(at: index)))", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "message at \(index) failed, expected \(comment.date), found \(String(describing: sut.commentDate(at: index)))", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "message at \(index) failed, expected \(comment.username), found \(String(describing: sut.commentUsername(at: index)))", file: file, line: line)
        }
    }
}
