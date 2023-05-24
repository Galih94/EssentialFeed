//
//  FeedViewController.swift
//  Prototype
//
//  Created by Galih Samudra on 24/05/23.
//

import UIKit
final class FeedViewController: UITableViewController {
    private let feed = FeedImageViewModel.protoTypeFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}
