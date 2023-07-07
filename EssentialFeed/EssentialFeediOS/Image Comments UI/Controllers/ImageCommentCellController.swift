//
//  ImageCommentController.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 07/07/23.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController {
    private let model: ImageCommentViewModel
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
}

extension ImageCommentCellController: CellController {
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        cell.messageLabel.text = model.messsage
        return cell
    }
}
