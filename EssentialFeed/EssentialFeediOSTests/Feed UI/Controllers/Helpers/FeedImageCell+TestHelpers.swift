//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 31/05/23.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}

