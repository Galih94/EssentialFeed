//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 05/06/23.
//

import UIKit
import EssentialFeed

final class FeedImageViewModel {
    private var task: FeedImageLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageLoader
    var onImageLoad: ((UIImage?) -> Void)?
    var onImageLoadingStateChange: ((Bool) -> Void)?
    var onShouldRetryImageLoadStateChange: ((Bool) -> Void)?
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var location: String? {
        return model.location
    }
    
    var description: String? {
        return model.description
    }
    
    
    init(model: FeedImage, imageLoader: FeedImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = self.imageLoader.loadImageData(from: self.model.url, completion: { [weak self] result in
            let data = try? result.get()
            let dataImage = data.flatMap(UIImage.init) ?? nil
            if let image = dataImage {
                self?.onImageLoad?(image)
            } else {
                self?.onShouldRetryImageLoadStateChange?(true)
            }
            self?.onImageLoadingStateChange?(false)
        })
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
}
