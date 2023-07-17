//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 17/07/23.
//

public struct Paginated<Item> {
    public typealias LoadMoreCompletion = (Result<Paginated<Item>, Error>) -> Void
    public let items: [Item]
    public let loadMore: ((@escaping LoadMoreCompletion) -> Void)?
    
    public init(items: [Item], loadMore: ((@escaping Paginated<Item>.LoadMoreCompletion) -> Void)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
