//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 13/06/23.
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let image = uniqueImage()
        let viewModel = FeedImagePresenter<ViewSpy, AnyImage>.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
    
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
    
    func test_didFinishLoadingImageData_displayRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()

        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        guard let message = view.messages.first else {
            return XCTFail("Expected found messages")
        }
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message.description, image.description)
        XCTAssertEqual(message.location, image.location)
        XCTAssertNil(message.image)
        XCTAssertEqual(message.isLoading, false)
        XCTAssertEqual(message.shouldRetry, true)
    }
    
    func test_didFinishLoadingImageData_displayImageOnSuccessfulImageTransformation() {
        let image = uniqueImage()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        guard let message = view.messages.first else {
            return XCTFail("Expected found messages")
        }
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message.description, image.description)
        XCTAssertEqual(message.location, image.location)
        XCTAssertEqual(message.image, transformedData)
        XCTAssertEqual(message.isLoading, false)
        XCTAssertEqual(message.shouldRetry, false)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let image = uniqueImage()
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        
        guard let message = view.messages.first else {
            return XCTFail("Expected found messages")
        }
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message.description, image.description)
        XCTAssertEqual(message.location, image.location)
        XCTAssertNil(message.image)
        XCTAssertEqual(message.isLoading, false)
        XCTAssertEqual(message.shouldRetry, true)
    }
    
    // MARK: -- Helpers
    
    private struct AnyImage: Equatable {}
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil}
    }
    
    private func makeSUT(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil},
        file: StaticString = #filePath,
        line: UInt = #line) -> (FeedImagePresenter<ViewSpy, AnyImage>, ViewSpy) {
        let view = ViewSpy()
            let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
    
    private final class ViewSpy: FeedImageView {
        var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
