//
//  FeedImageLoader.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 31/05/23.
//

public protocol FeedImageLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping(Result) -> Void) -> FeedImageLoaderTask
}
