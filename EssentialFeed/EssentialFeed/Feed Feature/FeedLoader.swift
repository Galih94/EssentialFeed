//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Galih Samodra Wicaksono on 04/05/23.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
