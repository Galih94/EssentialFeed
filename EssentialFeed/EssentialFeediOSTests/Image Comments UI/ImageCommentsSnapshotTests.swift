//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Galih Samudra on 07/07/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {

    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .dark)), named: "IMAGE_COMMENTS_dark")
        assert(snapshot: sut.snapshot(for: .iPhone14Pro(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_light_extraExtraExtraLarge")
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controlller = storyboard.instantiateInitialViewController() as! ListViewController
        controlller.loadViewIfNeeded()
        controlller.tableView.showsVerticalScrollIndicator = false
        controlller.tableView.showsHorizontalScrollIndicator = false
        
        trackForMemoryLeaks(controlller, file: file, line: line)
        
        return controlller
    }
    
    private func comments() -> [CellController] {
        return commentControllers().map{ CellController(id: UUID(), $0) }
    }
    
    private func commentControllers() -> [ImageCommentCellController]  {
        return [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    messsage: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long long username")),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    messsage: "East Side Gallery\nMemorial in Berlin, Germany",
                    date: "10 days ago",
                    username: "a username")),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    messsage: "nice pic",
                    date: "1 hour ago",
                    username: "a."))
        ]
    }

}
