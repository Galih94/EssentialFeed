//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 12/06/23.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var label: UILabel!
    
    public var message: String? {
        set { label.text = newValue}
        get { return label.text }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        label.text = nil
    }
}
