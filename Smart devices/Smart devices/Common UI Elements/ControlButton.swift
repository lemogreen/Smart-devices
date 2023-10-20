//
//  ControlButton.swift
//  Smart devices
//

import UIKit

final class ControlButton: UIControl {
    var iconImage: UIImage? {
        didSet {
            iconImageView.image = iconImage
        }
    }
    
    var activeBackgroundColor: UIColor? {
        didSet {
            updateButtonAppearance()
        }
    }
    
    var activeTintColor: UIColor? {
        didSet {
            updateButtonAppearance()
        }
    }
    
    var normalBackgroundColor: UIColor? {
        didSet {
            updateButtonAppearance()
        }
    }
    
    var normalTintColor: UIColor? {
        didSet {
            updateButtonAppearance()
        }
    }
    
    var touchUpInsideActionClosure: (() -> Void)?
    
    override var isSelected: Bool {
        didSet {
            updateButtonAppearance()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            iconImageView.tintColor = isEnabled ? activeTintColor : normalTintColor
            backgroundColor = isEnabled ? activeBackgroundColor : normalBackgroundColor
        }
    }
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray6
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview().inset(10)
        }
        
        addTarget(self, action: #selector(touchUpInsideAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ControlButton {
    func updateButtonAppearance() {
        iconImageView.tintColor = isSelected ? activeTintColor : normalTintColor
        backgroundColor = isSelected ? activeBackgroundColor : normalBackgroundColor
    }
    
    @objc
    func touchUpInsideAction() {
        touchUpInsideActionClosure?()
    }
}
