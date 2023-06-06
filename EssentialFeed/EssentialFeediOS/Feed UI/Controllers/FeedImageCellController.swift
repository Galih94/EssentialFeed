//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 02/06/23.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImage()
}

final class FeedImageCellController: FeedImageView {
    private lazy var cell = FeedImageCell()
    private let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !model.hasLocation
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.onRetry = delegate.didRequestImage
        
        cell.feedImageView.image = model.image
        cell.feedImageContainer.isShimmering = model.isLoading
        cell.feedImageRetryButton.isHidden = !model.shouldRetry
        
    } 
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    func cancelLoad() {
        delegate.didCancelImage()
    }
}
