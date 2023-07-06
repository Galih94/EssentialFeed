//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 06/07/23.
//

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
    public let messsage: String
    public let date: String
    public let username: String
    
    public init(messsage: String, date: String, username: String) {
        self.messsage = messsage
        self.date = date
        self.username = username
    }
}

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                                 tableName: "ImageComments",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Title for the Image Comments view")
    }
    
    public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        return ImageCommentsViewModel(comments: comments.map({ comment in
            return ImageCommentViewModel(
                messsage: comment.message,
                date: formatter.localizedString(for: comment.createdAt, relativeTo: Date()),
                username: comment.username)
        }))
    }
}
