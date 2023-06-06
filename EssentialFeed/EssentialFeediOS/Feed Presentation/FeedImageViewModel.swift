//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 05/06/23.
//

import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    private var task: FeedImageLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageLoader
    private let imageTransformer: (Data) -> Image?
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var location: String? {
        return model.location
    }
    
    var description: String? {
        return model.description
    }
    
    
    init(model: FeedImage, imageLoader: FeedImageLoader, imageTransformer: @escaping((Data) -> Image?)) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = self.imageLoader.loadImageData(from: self.model.url, completion: { [weak self] result in
            self?.handle(result)
        })
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
    // MARK: -- Helper
    private func handle(_ result: FeedImageLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
}
