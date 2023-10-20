//
//  VerticalSliderControl.swift
//  Smart devices
//

import UIKit
import SnapKit

final class VerticalSliderControl: UIControl {
    var maxValue: Int = 100 {
        didSet {
            if wrappedValue > maxValue { value = maxValue }
        }
    }
    
    var value: Int? {
        didSet {
            if oldValue ?? 0 != wrappedValue || oldValue == nil {
                sendActions(for: .valueChanged)
                
                if oldValue != nil && (wrappedValue == maxValue || wrappedValue == 0) {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
            
            scrollingIndicatorView.snp.updateConstraints { make in
                let percentage = CGFloat(wrappedValue) / CGFloat(maxValue)
                let inset = bounds.maxY - (bounds.maxY * percentage)
                make.top.equalToSuperview().inset(inset)
            }
        }
    }
    
    var scrollingIndicatorColor: UIColor? {
        didSet {
            scrollingIndicatorView.backgroundColor = scrollingIndicatorColor
        }
    }
    
    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
        }
    }
    
    var iconTint: UIColor? {
        didSet {
            iconImageView.tintColor = iconTint
        }
    }
    
    private var wrappedValue: Int {
        return value ?? 0 
    }
    
    private lazy var scrollingIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.5
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollingIndicatorView.snp.updateConstraints { make in
            let percentage = CGFloat(wrappedValue) / CGFloat(maxValue)
            let inset = bounds.maxY - (bounds.maxY * percentage)
            make.top.equalToSuperview().inset(inset)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VerticalSliderControl {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchLocation = touch.location(in: self)
        
        if touchLocation.y < bounds.minY {
            value = maxValue
            return true
        }
        
        if touchLocation.y > bounds.maxY {
            value = 0
            return true
        }
        
        let height = bounds.minY - bounds.maxY
        let percentage = touchLocation.y / height + 1
        value = Int(percentage * CGFloat(maxValue))
        
        return true
    }
    
    // Check if there is no PanGestureRecognizer from .styleSheet modal presentation
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(gestureRecognizer is UIPanGestureRecognizer)
    }
}

private extension VerticalSliderControl {
    func setupUI() {
        addSubview(scrollingIndicatorView)
        scrollingIndicatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().priority(.high)
            make.top.equalToSuperview().inset(0)
        }
        
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
            make.height.width.equalTo(40)
        }
    }
}
