//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Galih Samudra on 20/06/23.
//

import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        

        // learn UI test
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL
            .appending(path: "feed-store.sqlite")
        #if DEBUG
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        #endif
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localStoreFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        
        window?.rootViewController = FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localStoreFeedLoader),
                fallback: localStoreFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primaryLoader: localImageLoader,
                fallbackLoader: FeedImageDataLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader)))
        
        // learn composite
//        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
//        let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
//        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
//        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
//
//        let localStoreURL = NSPersistentContainer.defaultDirectoryURL.appending(path: "feed-store.sqlite")
//        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
//        let localStoreFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
//        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
//
//        let feedViewController = FeedUIComposer.feedComposedWith(
//            feedLoader: FeedLoaderWithFallbackComposite(
//                primary: FeedLoaderCacheDecorator(
//                    decoratee: remoteFeedLoader,
//                    cache: localStoreFeedLoader),
//                fallback: localStoreFeedLoader),
//            imageLoader: FeedImageDataLoaderWithFallbackComposite(
//                primaryLoader: localImageLoader,
//                fallbackLoader: FeedImageDataLoaderCacheDecorator(
//                    decoratee: remoteImageLoader,
//                    cache: localImageLoader)))
        
        // use local loader only to test local cache
//        let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: localStoreFeedLoader,
//                                                                 imageLoader: localImageLoader)
//        window?.rootViewController = feedViewController
    }
    
    private func makeRemoteClient() -> HTTPClient {
        #if DEBUG
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        #endif
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}

#if DEBUG
private class AlwaysFailingHTTPClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
    
}
#endif
