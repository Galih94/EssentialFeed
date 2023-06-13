//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 13/06/23.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
    func display(_ model: FeedImageViewModel)
}

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

final class FeedImagePresenter {
    private let view: FeedImageView
    init(view: FeedImageView) {
        self.view = view
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            FeedImageViewModel(description: model.description,
                               location: model.location,
                               image: nil,
                               isLoading: true,
                               shouldRetry: false))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messaged")
    }
    
    func test_didStartLoadingImageData_displayLoadingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingImageData(for: image)
        
        guard let message = view.messages.first else {
            return XCTFail("Expected found messages")
        }
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message.description, image.description)
        XCTAssertEqual(message.location, image.location)
        XCTAssertNil(message.image)
        XCTAssertEqual(message.isLoading, true)
        XCTAssertEqual(message.shouldRetry, false)
    }
    
    // MARK: -- Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedImagePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
    
    private final class ViewSpy: FeedImageView {
        var messages = [FeedImageViewModel]()
        
        func display(_ model: FeedImageViewModel) {
            messages.append(model)
        }
    }
}
