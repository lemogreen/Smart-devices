//
//  DeviceCollectionViewCell.swift
//  Smart devices
//

import UIKit
import SnapKit

private enum DeviceCollectionViewCellConfigurator {
    static var deviceNameFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    static var descriptionFont = UIFont.systemFont(ofSize: 16, weight: .medium)
}

final class DeviceCollectionViewCell: UICollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.transform = self.isHighlighted ? .init(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }
    
    private lazy var deviceNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = DeviceCollectionViewCellConfigurator.deviceNameFont
        label.textColor = Asset.Colors.deviceCellNameActive.color
        label.alpha = 0.8
        return label
    }()
    
    private lazy var deviceDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = DeviceCollectionViewCellConfigurator.descriptionFont
        label.alpha = 0.5
        label.contentMode = .bottom
        return label
    }()
    
    private lazy var visualEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: effect)
        return visualEffectView
    }()
    
    private lazy var deviceIconImageView = UIImageView()
    private lazy var additionalInfoStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with configuration: Device) {
        additionalInfoStackView.clear()
        
        deviceNameLabel.text = configuration.deviceName
        deviceIconImageView.image = configuration.deviceType.deviceIconImage
        deviceNameLabel.textColor = configuration.deviceType.deviceNameLabelColor
        deviceDescriptionLabel.text = configuration.deviceType.deviceDescriptionText
        deviceDescriptionLabel.textColor = configuration.deviceType.deviceDescriptionLabelColor
        additionalInfoStackView.addArrangedSubview(deviceDescriptionLabel)
        
        backgroundColor = configuration.deviceType.deviceCellBackgroundColor
    }
}

private extension DeviceCollectionViewCell {
    func setupCell() {
        addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { $0.top.left.right.bottom.equalToSuperview() }
        
        visualEffectView.contentView.addSubview(deviceIconImageView)
        deviceIconImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(10)
            make.right.lessThanOrEqualToSuperview().inset(10)
            make.height.width.equalTo(30)
        }
        
        visualEffectView.contentView.addSubview(deviceNameLabel)
        deviceNameLabel.snp.makeConstraints { make in
            make.top.equalTo(deviceIconImageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
        }
        
        visualEffectView.contentView.addSubview(additionalInfoStackView)
        additionalInfoStackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(deviceNameLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10).priority(.medium)
        }
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}

private extension Device.DeviceType {
    var deviceIconImage: UIImage {
        switch self {
        case .light(let mode, _):
            return mode
            ? Asset.Images.Device.deviceLightOnIcon.image
            : Asset.Images.Device.deviceLightOffIcon.image
        case .heater(let mode, _):
            return mode
            ? Asset.Images.Device.deviceHeaterOnIcon.image
            : Asset.Images.Device.deviceHeaterOffIcon.image
        case .rollerShutter:
            return Asset.Images.Device.deviceRollerShutterIcon.image
        }
    }
    
    var deviceNameLabelColor: UIColor {
        switch self {
        case .light(let mode, _):
            return mode
            ? Asset.Colors.deviceCellNameActive.color
            : Asset.Colors.deviceCellNameInactive.color
        case .heater(let mode, _):
            return mode
            ? Asset.Colors.deviceCellNameActive.color
            : Asset.Colors.deviceCellNameInactive.color
        case .rollerShutter:
            return Asset.Colors.deviceCellNameActive.color
        }
    }
    
    var deviceDescriptionLabelColor: UIColor {
        switch self {
        case .light(let mode, _):
            return mode
            ? Asset.Colors.deviceCellNameActive.color
            : Asset.Colors.deviceCellNameInactive.color
        case .heater(let mode, _):
            return mode
            ? Asset.Colors.deviceCellNameActive.color
            : Asset.Colors.deviceCellNameInactive.color
        case .rollerShutter:
            return Asset.Colors.deviceCellNameActive.color
        }
    }
    
    var deviceCellBackgroundColor: UIColor {
        switch self {
        case .light(let mode, _):
            return mode
            ? Asset.Colors.deviceCellBackgroundActive.color
            : Asset.Colors.deviceCellBackgroundInactive.color
        case .heater(let mode, _):
            return mode
            ? Asset.Colors.deviceCellBackgroundActive.color
            : Asset.Colors.deviceCellBackgroundInactive.color
        case .rollerShutter:
            return Asset.Colors.deviceCellBackgroundActive.color
        }
    }
    
    var deviceDescriptionText: String {
        switch self {
        case let .light(mode, intensity):
            guard mode else { return L10n.DevicesList.Cells.Lights.off }
            return L10n.DevicesList.Cells.Lights.intensity(intensity)
        case let .heater(mode, temperature):
            guard mode else { return L10n.DevicesList.Cells.Heater.off }
            return L10n.DevicesList.Cells.Heater.temperature(temperature)
        case .rollerShutter(let position):
            if position == 100 { return L10n.DevicesList.Cells.RollerShutter.opened }
            if position == 0 { return L10n.DevicesList.Cells.RollerShutter.closed }
            return L10n.DevicesList.Cells.RollerShutter.openedAtPosition(position)
        }
    }
}
