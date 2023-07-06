//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 02/06/23.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImage()
}

public final class FeedImageCellController: FeedImageView {
    public typealias ResourceViewModel = UIImage
    private var cell: FeedImageCell?
    private let delegate: FeedImageCellControllerDelegate
    private let viewModel: FeedImageViewModel<UIImage>
    
    public init(viewModel: FeedImageViewModel<UIImage>, delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        self.viewModel = viewModel
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    public func display(_ model: FeedImageViewModel<UIImage>) {
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestImage()
        }
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

extension FeedImageCellController: ResourceView {
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
}

extension FeedImageCellController: ResourceLoadingView {
    public func display(_ viewModel: EssentialFeed.ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
}

extension FeedImageCellController: ResourceErrorView {
    public func display(_ viewModel: EssentialFeed.ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }
}
