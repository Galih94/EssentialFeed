//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Galih Samudra on 14/06/23.
//

import XCTest
import EssentialFeed

public final class RemoteFeedImageDataLoader {
    private final class HTTPClientTaskWrappper: FeedImageDataLoaderTask {
        var wrapped: HTTPClientTask?
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: (@escaping (FeedImageDataLoader.Result) -> Void) ) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrappper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            case let .failure(error):
                task.complete(with: .failure(error))
            }
        }
        return task
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageData_requestDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        
        expect(sut: sut, toCompeteWith: .failure(error)) {
            client.complete(with: error)
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let error = failure(.invalidData)
        let data = anyData()
        let codes = [199, 201, 300, 400, 500]
        
        codes.enumerated().forEach { index, code in
            expect(sut: sut, toCompeteWith: error) {
                client.complete(with: data, code: code, at: index)
            }
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let error = failure(.invalidData)
        let emptyData = Data()
        let code = 200
        
        expect(sut: sut, toCompeteWith: error) {
            client.complete(with: emptyData, code: code, at: 0)
        }
    }
    
    func test_loadImageData_deliversDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let data = anyData()
        let code = 200
        
        expect(sut: sut, toCompeteWith: .success(data)) {
            client.complete(with: data, code: code)
        }
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadImageData_doesNotDeloverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        var receivedResult = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { result in
            receivedResult.append(result)
        }
        task.cancel()
        
        client.complete(with: anyData(), code: 404)
        client.complete(with: nonEmptyData, code: 200)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageData_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        let data = anyData()
        let code = 200
        let url = anyURL()
        
        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: url, completion: { result in
            capturedResults.append(result)
        })
        
        sut = nil
        client.complete(with: data, code: code)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(sut: RemoteFeedImageDataLoader, toCompeteWith expectedResult: FeedImageDataLoader.Result, action: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for load image")
        sut.loadImageData(from: url) { receivedResult in
            
            switch (receivedResult, expectedResult) {
                
            case let ( .success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default: XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            let callback: () -> Void
            func cancel() {
                callback()
            }
        }
        
        var cancelledURLs = [URL]()
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        var requestedURLs : [URL] {
            return messages.map{ $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success((data, response)))
        }
    }
}
