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
    private var cell: FeedImageCell?
    private let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !model.hasLocation
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.onRetry = delegate.didRequestImage
        
        cell?.feedImageView.setImageAnimated(model.image)
        cell?.feedImageContainer.isShimmering = model.isLoading
        cell?.feedImageRetryButton.isHidden = !model.shouldRetry
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
    } 
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImage()
    }
    
    // MARK: Helpers
    private func releaseCellForReuse() {
        cell = nil
    }
}
