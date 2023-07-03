//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Galih Samodra Wicaksono on 04/05/23.
//

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>
public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}
