//
//  HeaterControlViewController.swift
//  Smart devices
//

import UIKit
import RxSwift

private enum HeaterControlViewControllerConfigurator {
    static var heaterValueFont: UIFont {
        let fontSize: CGFloat = 80
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let descriptor = font.fontDescriptor.withDesign(.rounded)
        guard let descriptor = descriptor else { return font }
        return UIFont(descriptor: descriptor, size: fontSize)
    }
}

final class HeaterControlViewController: UIViewController {
    var viewModel: HeaterControlViewModel!
    
    private let disposeBag = DisposeBag()
    
    private lazy var heaterTemperatureControl: HeaterTemperatureControl = {
        let heaterTemperatureControl = HeaterTemperatureControl()
        return heaterTemperatureControl
    }()
    
    private lazy var deviceDescriptionView = DeviceDescriptionView()
    
    private lazy var powerButton: ControlButton = {
        let button = ControlButton()
        button.activeTintColor = .systemGray6
        button.activeBackgroundColor = .systemOrange
        button.normalTintColor = .systemGray6
        button.normalBackgroundColor = .systemGray
        button.iconImage = UIImage(systemName: "power")
        button.touchUpInsideActionClosure = {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 40
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        view.backgroundColor = .systemBackground
        
        view.addSubview(deviceDescriptionView)
        deviceDescriptionView.snp.makeConstraints { $0.top.left.right.equalToSuperview() }
        
        stackView.addArrangedSubview(heaterTemperatureControl)
        
        stackView.addArrangedSubview(powerButton)
        powerButton.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(deviceDescriptionView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().inset(40)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        handleDeviceOrientation()
    }
}

extension HeaterControlViewController: ViewModelBindable {
    func bind() {
        let viewWillAppearSignal = rx.viewWillAppear
            .take(1)
            .asSignal(onErrorSignalWith: .never())
            .map { _ in }
        
        let didTapPowerButton = powerButton.rx.controlEvent(.touchUpInside).asSignal()
        
        let heaterTemperature = heaterTemperatureControl.rx.controlEvent(.valueChanged)
            .asSignal()
            .map { [weak self] _ in self?.heaterTemperatureControl.value }
        
        let didTapCloseButton = deviceDescriptionView.rx.didTapCloseButton
                
        let input = ViewModel.Input(
            viewWillAppearSignal: viewWillAppearSignal,
            didTapPowerButton: didTapPowerButton,
            heaterTemperature: heaterTemperature,
            didTapCloseButton: didTapCloseButton
        )
        
        let output = viewModel.transform(input)
        
        output.title
            .drive(deviceDescriptionView.rx.deviceName)
            .disposed(by: disposeBag)
        
        output.heaterValueDescription
            .drive(deviceDescriptionView.rx.deviceDescription)
            .disposed(by: disposeBag)
        
        output.powerButtonIsSelected.drive(powerButton.rx.isSelected).disposed(by: disposeBag)
        output.heaterInitialValue.drive(heaterTemperatureControl.rx.value).disposed(by: disposeBag)
                
        output.pullcord.emit().disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.handleDeviceOrientation() })
            .disposed(by: disposeBag)
    }
}

private extension HeaterControlViewController {
    func handleDeviceOrientation() {
        stackView.axis = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
    }
}
