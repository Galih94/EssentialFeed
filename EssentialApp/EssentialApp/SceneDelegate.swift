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
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer
            .defaultDirectoryURL
            .appending(path: "feed-store.sqlite"))
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func configureWindow() {
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        let localStoreFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localStoreFeedLoader),
                fallback: localStoreFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primaryLoader: localImageLoader,
                fallbackLoader: FeedImageDataLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader))))
    }
}
