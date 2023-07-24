//
//  FeedImageLoader.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 31/05/23.
//

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
