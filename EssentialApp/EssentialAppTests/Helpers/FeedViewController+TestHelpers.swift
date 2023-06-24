//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 31/05/23.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
    var errorMessage: String? {
        return errorView?.message
    }
    
    var isShowingLoadingIndicator: Bool? {
        return refreshControl?.isRefreshing
    }
    
    private var feedImagesSection: Int {
        return 0
    }
    
    func simulateInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        guard let view = simulateFeedImageViewVisible(at: row) else { return nil }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view, forRowAt: index)
        return view
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func renderedFeedImageData(at index: Int)-> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    @discardableResult
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else { return nil }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}
