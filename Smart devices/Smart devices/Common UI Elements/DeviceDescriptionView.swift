//
//  DeviceDescriptionView.swift
//  Smart devices
//

import UIKit
import RxSwift
import RxCocoa

private enum DeviceDescriptionViewConfigurator {
    static var deviceNameFont = UIFont.systemFont(ofSize: 20, weight: .heavy)
    static var descriptionFont = UIFont.systemFont(ofSize: 18, weight: .bold)
}

final class DeviceDescriptionView: UIView {
    var deviceName: String? {
        didSet {
            deviceNameLabel.text = deviceName
        }
    }
    
    var deviceDescription: String? {
        didSet {
            descriptionLabel.text = deviceDescription
        }
    }
    
    private lazy var deviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = DeviceDescriptionViewConfigurator.deviceNameFont
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = DeviceDescriptionViewConfigurator.descriptionFont
        return label
    }()
    
    fileprivate lazy var closeButton: RoundedButton = {
        let button = RoundedButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.backgroundColor = .lightGray.withAlphaComponent(0.8)
        button.tintColor = .systemGray6
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: DeviceDescriptionView {
    var didTapCloseButton: Signal<Void> {
        base.closeButton.rx.tap.asSignal()
    }
}

private extension DeviceDescriptionView {
    func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(deviceNameLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.left.equalToSuperview().inset(20)
            make.right.equalTo(closeButton.snp.left).inset(-10)
        }
    }
}
