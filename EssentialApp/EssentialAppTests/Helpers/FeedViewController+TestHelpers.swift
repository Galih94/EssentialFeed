//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 31/05/23.
//

import UIKit
import EssentialFeediOS

// MARK: General
extension ListViewController {
    var errorMessage: String? {
        return errorView.message
    }
    
    var isShowingLoadingIndicator: Bool? {
        return refreshControl?.isRefreshing
    }
    
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    func simulateInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
}


// MARK: Comments
extension ListViewController {
    private var commentsSection: Int {
        return 0
    }
    
    func numberOfRenderedComments() -> Int {
        return tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        return commentView(at: row)?.messageLabel.text
    }
    func commentDate(at row: Int) -> String? {
        return commentView(at: row)?.dateLabel.text
    }
    func commentUsername(at row: Int) -> String? {
        return commentView(at: row)?.usernameLabel.text
    }
    
    private func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedComments() > row else { return nil }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }
}

// MARK: Feed
extension ListViewController {
    private var feedImagesSection: Int {
        return 0
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
        return tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    @discardableResult
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else { return nil }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}
