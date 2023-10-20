//
//  HeaterTemperatureControl.swift
//  Smart devices
//

import UIKit

private enum HeaterTemperatureControlConfigurator {
    static var heaterValueFont: UIFont {
        let fontSize: CGFloat = 80
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let descriptor = font.fontDescriptor.withDesign(.rounded)
        guard let descriptor = descriptor else { return font }
        return UIFont(descriptor: descriptor, size: fontSize)
    }
}

final class HeaterTemperatureControl: UIControl {
    var minValue: Decimal = 7 {
        didSet {
            assert(maxValue < minValue, "Not possible condition. maxValue < minValue")
            assert(maxValue == minValue, "Not possible condition. maxValue = minValue")
            if value < minValue { value = minValue }
        }
    }
    
    var maxValue: Decimal = 28 {
        didSet {
            assert(maxValue < minValue, "Not possible condition. maxValue < minValue")
            assert(maxValue == minValue, "Not possible condition. maxValue = minValue")
            if value > maxValue { value = maxValue }
        }
    }
    
    var step: Decimal = 0.5 {
        didSet {
            assert(step == 0, "Step can't be equal to zero")
        }
    }
    
    var value: Decimal = 10 {
        didSet {
            guard value != oldValue else { return }
            increaseButton.isEnabled = value != maxValue
            decreaseButton.isEnabled = value != minValue
            temperatureLabel.text = "\(value)°C"
            sendActions(for: .valueChanged)
        }
    }
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = HeaterTemperatureControlConfigurator.heaterValueFont
        label.allowsDefaultTighteningForTruncation = true
        return label
    }()
    
    private lazy var increaseButton = createButton(with: UIImage(systemName: "plus"))
    private lazy var decreaseButton = createButton(with: UIImage(systemName: "minus"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension HeaterTemperatureControl {
    func setupUI() {
        addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }
        
        let stackView = UIStackView()
        stackView.spacing = 30
        
        increaseButton.snp.makeConstraints { $0.width.height.equalTo(50) }
        decreaseButton.snp.makeConstraints { $0.width.height.equalTo(50) }
        
        stackView.addArrangedSubview(decreaseButton)
        stackView.addArrangedSubview(increaseButton)
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    func setupActions() {
        increaseButton.addTarget(self, action: #selector(didTapIncreaseButton), for: .touchUpInside)
        decreaseButton.addTarget(self, action: #selector(didTapDecreaseButton), for: .touchUpInside)
    }
    
    func createButton(with icon: UIImage?) -> ControlButton {
        let button = ControlButton()
        button.iconImage = icon
        button.activeTintColor = .systemGray6
        button.activeBackgroundColor = .systemOrange
        button.normalTintColor = .systemGray6
        button.normalBackgroundColor = .systemGray
        button.touchUpInsideActionClosure = {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        return button
    }
    
    @objc
    func didTapIncreaseButton() {
        let newValue = value + step
        if value < maxValue && newValue >= maxValue {
            value = maxValue
            return
        }
        if value < maxValue && newValue < maxValue {
            value = newValue
            return
        }
    }
    
    @objc
    func didTapDecreaseButton() {
        let newValue = value - step
        if value > minValue && newValue <= minValue {
            value = minValue
            return
        }
        if value > minValue && newValue > minValue {
            value = newValue
            return
        }
    }
}
