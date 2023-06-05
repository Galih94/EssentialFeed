//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 02/06/23.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    private let viewModel: FeedViewModel
    var onRefresh: (([FeedImage]) -> Void)?
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    init(feedLoader: FeedLoader? = nil) {
        self.viewModel = FeedViewModel(feedLoader: feedLoader)
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
            if let feed = viewModel.feed {
                self?.onRefresh?(feed)
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
}
