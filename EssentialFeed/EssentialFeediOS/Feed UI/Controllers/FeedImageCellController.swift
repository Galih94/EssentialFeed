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

public final class FeedImageCellController: NSObject {
    public typealias ResourceViewModel = UIImage
    private var cell: FeedImageCell?
    private let delegate: FeedImageCellControllerDelegate
    private let viewModel: FeedImageViewModel
    
    public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        self.viewModel = viewModel
    }
    
    // MARK: Helpers
    private func releaseCellForReuse() {
        cell = nil
    }
    
    private func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImage()
    }
}

extension FeedImageCellController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
}

extension FeedImageCellController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
}

extension FeedImageCellController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestImage()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
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
