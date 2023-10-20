//
//  UIDevice+Ext.swift
//  Smart devices
//

import UIKit

extension UIScreen {
    enum SizeType {
        case extraSmall
        case small
        case medium
        case large
        case extraLarge
        case none
    }
    
    static var sizeClass: SizeType {
        guard let height = [main.bounds.height, main.bounds.width].max() else { return .none }
        switch height {
        case let x where x < 600:
            return .extraSmall
        case let x where x < 700:
            return .small
        case let x where x < 800:
            return .medium
        case let x where x < 1000:
            return .large
        case let x where x >= 1000:
            return .extraLarge
        default:
            return .none
        }
    }
}
