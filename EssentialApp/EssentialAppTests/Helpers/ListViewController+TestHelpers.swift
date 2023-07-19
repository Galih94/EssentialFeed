//
//  ListViewController+TestHelpers.swift
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
    
    func numberOfRows(in section: Int) -> Int {
        return tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(for row: Int, in section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else { return nil }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}


// MARK: Comments
extension ListViewController {
    private var commentsSection: Int {
        return 0
    }
    
    func numberOfRenderedComments() -> Int {
        return numberOfRows(in: commentsSection)
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
        return cell(for: row, in: commentsSection) as? ImageCommentCell
    }
}

// MARK: Feed
extension ListViewController {
    private var feedImagesSection: Int {
        return 0
    }
    
    private var feedLoadMoreSection: Int {
        return 1
    }
    
    private var feedFirstRow: Int {
        return 0
    }
    
    var loadMoreFeedErrorMessage: String? {
        return loadMoreFeedCell()?.message
    }
    
    var isShowingLoadMoreFeedIndicator: Bool {
        return loadMoreFeedCell()?.isLoading == true
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        return cell(for: feedFirstRow, in: feedLoadMoreSection) as? LoadMoreCell
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
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func renderedFeedImageData(at index: Int)-> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return numberOfRows(in: feedImagesSection)
    }
    
    @discardableResult
    func feedImageView(at row: Int) -> UITableViewCell? {
        return cell(for: row, in: feedImagesSection)
    }
    
    func simulateLoadMoreFeedAction() {
        guard let view = loadMoreFeedCell() else { return }
        let delegate = tableView.delegate
        let index = IndexPath(row: feedFirstRow, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    func simulateTapOnLoadMoreFeedError() {
        let delegate = tableView.delegate
        let index = IndexPath(row: feedFirstRow, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
}
