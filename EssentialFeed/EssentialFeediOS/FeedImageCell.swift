//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 30/05/23.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public var locationContainer = UIView()
    public var locationLabel = UILabel()
    public var descriptionLabel = UILabel()
    public var feedImageContainer = UIView()
    public var feedImageView = UIImageView()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: ( () -> Void )?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
