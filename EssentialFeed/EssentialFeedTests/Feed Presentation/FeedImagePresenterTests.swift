//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 13/06/23.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            FeedImageViewModel(description: model.description,
                               location: model.location,
                               image: nil,
                               isLoading: true,
                               shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(
            FeedImageViewModel(description: model.description,
                               location: model.location,
                               image: image,
                               isLoading: false,
                               shouldRetry: image == nil))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(
            FeedImageViewModel(description: model.description,
                               location: model.location,
                               image: nil,
                               isLoading: false,
                               shouldRetry: true))
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
    
    func test_didFinishLoadingImageData_displayRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()
        let data = Data()

        sut.didFinishLoadingImageData(with: data, for: image)
        
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
        let data = Data()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

        sut.didFinishLoadingImageData(with: data, for: image)
        
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
