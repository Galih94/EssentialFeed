//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 24/06/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: HTTPClientStub.online(response), store: InMemoryStore.empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryStore.empty
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(httpClient: .offline, store: sharedStore)
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData1())
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryStore.withExpiredFeedCache
        
        enteringBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryStore.withNonExpiredFeedCache
        
        enteringBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }
    
    func test_onFeedImageSelection_displayComments() {
        let comments = showCommentsForFirstImage()

        XCTAssertEqual(comments.numberOfRenderedComments(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
    }
    
    // MARK: Helpers
    private func enteringBackground(with store: FeedStore & FeedImageDataStore ) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func launch(httpClient: HTTPClientStub = .offline,
                        store: InMemoryStore = .empty) -> ListViewController {
        
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        let feed = nav?.topViewController as! ListViewController
        
        return feed
    }
    
    private func showCommentsForFirstImage() -> ListViewController {
        let feed = launch(httpClient: HTTPClientStub.online(response), store: InMemoryStore.empty)
        
        feed.simulateTapOnFeedImage(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = feed.navigationController
        return nav?.topViewController as! ListViewController
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        let lastPath = "/\(url.lastPathComponent)"
        switch lastPath {
        case "/image-1":
            return makeImageData0()
        case "/image-2":
            return makeImageData1()
        case "/feed":
            return makeFeedData()
        case "/comments":
            return makeCommentsData()
        default:
            return Data()
        }
    }
    
    private func makeImageData0() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeImageData1() -> Data {
        return UIImage.make(withColor: .green).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [ "items": [
            ["id": "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086", "image": "http://feed.com/image-1"],
            ["id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A", "image": "http://feed.com/image-2"]
        ]])
    }
    
    private func makeCommentsData() -> Data {
        let jsonObj = [
            "items": [
                [
                    "id": UUID().uuidString,
                    "message": makeCommentMessage(),
                    "created_at": "2020-08-28T15:07:02+00:00",
                    "author": [
                        "username": "a username"
                    ]
                ] as [String : Any]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: jsonObj)
    }
    
    private func makeCommentMessage() -> String {
        return "a message"
    }
}
