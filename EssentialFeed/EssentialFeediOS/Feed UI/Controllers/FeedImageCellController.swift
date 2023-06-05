//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 02/06/23.
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

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel
    
    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
}
