//
//  UIStackView+Ext.swift
//  Smart devices
//

import UIKit

extension UIStackView {
    func clear() {
        for arrangedSubview in arrangedSubviews {
            removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
    }
}
