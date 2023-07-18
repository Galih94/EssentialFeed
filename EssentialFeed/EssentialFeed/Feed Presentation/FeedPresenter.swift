//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 13/06/23.
//

public final class FeedPresenter {
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
}
