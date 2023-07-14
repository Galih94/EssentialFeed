//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 12/06/23.
//

import UIKit

public final class ErrorView: UIButton {
    
    public var onHide:( () -> Void )?
    
    public var message: String? {
        set { setMessageAnimated(newValue) }
        get { return isVisible ? title(for: .normal) : nil }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var isVisible: Bool {
        return alpha > 0
    }
    private func configure() {
        backgroundColor = .errorBackGroundColor
        configuration = .plain()
        configuration?.titlePadding = 0
        configuration?.baseForegroundColor = .white
        configuration?.background.cornerRadius = 0
        configureLabel()
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        hideMessage()
    }
    
    private func configureLabel() {
        titleLabel?.textColor = .white
        titleLabel?.textAlignment = .center
        titleLabel?.tintColor = .white
        titleLabel?.numberOfLines = 0
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    private func hideMessage() {
        setTitle(nil, for: .normal)
        configuration!.contentInsets = NSDirectionalEdgeInsets(top: -2.5, leading: 0, bottom: 0, trailing: 0)
        alpha = 0
        onHide?()
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        setTitle(message, for: .normal)
        configuration!.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0},
            completion: { completed in
                if completed { self.hideMessage() }
        })
    }
}

extension UIColor {
    static var errorBackGroundColor: UIColor {
        return UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
