//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 13/06/23.
//

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        return FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
