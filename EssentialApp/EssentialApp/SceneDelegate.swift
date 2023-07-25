//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Galih Samudra on 20/06/23.
//

import os
import UIKit
import CoreData
import Combine
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.essentialdeveloper.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private lazy var logger = Logger(subsystem: "com.galih.EssentialApp", category: "main") /// Logger to log event in code
    
    private lazy var navigationController: UINavigationController =  UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeLocalImageLoaderWithRemoteFallback,
                selection: showComments))
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var baseURL: URL = {
        return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(storeURL: NSPersistentContainer
                .defaultDirectoryURL
                .appending(path: "feed-store.sqlite"))
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    convenience init(
        httpClient: HTTPClient,
        store: FeedStore & FeedImageDataStore,
        scheduler: AnyDispatchQueueScheduler ) {
            self.init()
            self.httpClient = httpClient
            self.store = store
            self.scheduler = scheduler
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func showComments(_ image: FeedImage) {
        let remoteURL = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeCommentsLoader(from: remoteURL))
        navigationController.pushViewController(comments, animated: true)
    }
    
    typealias CommentsLoader = () -> AnyPublisher<[ImageComment], Error>
    private func makeCommentsLoader(from url: URL) -> CommentsLoader {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        return makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage>  {
        return makePage(items: items, lastItem: items.last)
    }
    
    private func makeRemoteLoadMoreLoader(lastItem: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        return localFeedLoader.loadPublisher()
            .zip(makeRemoteFeedLoader(lastItem: lastItem))
            .map { (cachedItems, newItems) in
                return (cachedItems + newItems, newItems.last)
            }
            .map(makePage)
            .caching(to: localFeedLoader)
    }
    
    private func makePage(items: [FeedImage], lastItem: FeedImage?) -> Paginated<FeedImage> {
        return Paginated(
            items: items,
            loadMorePublisher: lastItem.map { [makeRemoteLoadMoreLoader] lastItem in
                return {
                    makeRemoteLoadMoreLoader(lastItem)
                }
        })
    }
    
    private func makeRemoteFeedLoader(lastItem: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error>  {
        let url = FeedEndpoint.get(after: lastItem).url(baseURL: baseURL)
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(from url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(url)
            .logCacheMisses(url: url, logger: logger)
            .fallback(to: { [logger, httpClient, scheduler] in
                return httpClient.getPublisher(url: url)
                    .logErrors(url: url, logger: logger)
                    .logElapsedTime(url: url, logger: logger)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, for: url)
                    .subscribe(on: scheduler)
                    .eraseToAnyPublisher()
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
}

extension Publisher {
    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveCompletion: { result in
            if case .failure = result {
                logger.trace("Cache miss for url: \(url)")
            }
        }).eraseToAnyPublisher()
    }
    
    func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.trace("Failed loading url: \(url) with error: \(error)")
            }
        }).eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        var startTime = CACurrentMediaTime()
        return handleEvents(receiveSubscription: { _ in
            logger.trace("Started loading url: \(url)")
            startTime = CACurrentMediaTime()
        }, receiveCompletion: { result in
            let elapsedTime = CACurrentMediaTime() - startTime
            logger.trace("Finished loading url: \(url), in \(elapsedTime) seconds")
        }, receiveCancel: {
            let elapsedTime = CACurrentMediaTime() - startTime
            logger.trace("Cancel loading url: \(url) , in \(elapsedTime) seconds")
        }).eraseToAnyPublisher()
    }
}

//extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}
//
//public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>
//public extension RemoteImageCommentsLoader {
//    convenience init(url: URL, client: HTTPClient) {
//        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
//    }
//}

//public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>
//public extension RemoteFeedLoader {
//    convenience init(url: URL, client: HTTPClient) {
//        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
//    }
//}
