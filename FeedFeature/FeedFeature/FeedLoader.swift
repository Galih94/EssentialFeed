//
//  FeedLoader.swift
//  FeedFeature
//
//  Created by Galih Samodra Wicaksono on 03/05/23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
