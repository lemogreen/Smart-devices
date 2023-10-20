//
//  LightControlViewController.swift
//  Smart devices
//

import UIKit
import RxCocoa
import RxSwift

final class LightControlViewController: UIViewController {
    var viewModel: LightControlViewModel!
    
    private let disposeBag = DisposeBag()
    
    private lazy var lightIntensityControl = VerticalSliderControl()
    private lazy var deviceDescriptionView = DeviceDescriptionView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
}

extension LightControlViewController: ViewModelBindable {
    func bind() {
        let viewWillAppearSignal = rx.viewWillAppear
            .take(1)
            .asSignal(onErrorSignalWith: .never())
            .map { _ in }
        
        let lightIntensityControlValueChanged = lightIntensityControl
            .rx
            .controlEvent(.valueChanged)
            .asSignal()
            .map { [weak lightIntensityControl] _ in lightIntensityControl?.value }

        let didTapCloseButton = deviceDescriptionView.rx.didTapCloseButton
        
        let input = ViewModel.Input(
            viewWillAppearSignal: viewWillAppearSignal,
            lightIntensityControlValueChanged: lightIntensityControlValueChanged,
            didTapCloseButton: didTapCloseButton
        )
        
        let output = viewModel.transform(input)
        
        output.title
            .drive(deviceDescriptionView.rx.deviceName)
            .disposed(by: disposeBag)
        
        output.lightIntenistyDescriptionString
            .drive(deviceDescriptionView.rx.deviceDescription)
            .disposed(by: disposeBag)
        
        output.lightControlInitialValue
            .drive(lightIntensityControl.rx.value)
            .disposed(by: disposeBag)
        
        output.pullcord.emit().disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.handleDeviceOrientation() })
            .disposed(by: disposeBag)
    }
}

private extension LightControlViewController {
    func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(deviceDescriptionView)
        deviceDescriptionView.snp.makeConstraints { $0.top.left.right.equalToSuperview() }
        
        view.addSubview(lightIntensityControl)
        makeLightIntensityControlConstraints()
        
        setupLightIntensityControl()
    }
    
    func setupLightIntensityControl() {
        lightIntensityControl.backgroundColor = Asset
            .Colors
            .lightControlBackground
            .color
        
        lightIntensityControl.scrollingIndicatorColor = Asset
            .Colors
            .lightControllScrollBackground
            .color
        
        lightIntensityControl.icon = Asset
            .Images
            .Device
            .deviceLightOffIcon
            .image
            .withRenderingMode(.alwaysTemplate)
        
        lightIntensityControl.iconTint = .systemGray6
        
        lightIntensityControl.layer.cornerRadius = 30
        lightIntensityControl.layer.masksToBounds = true
    }
    
    func makeLightIntensityControlConstraints() {
        if UIDevice.current.orientation.isLandscape {
            lightIntensityControl.snp.makeConstraints { make in
                make.top.equalTo(deviceDescriptionView.snp.bottom).offset(20)
                make.bottom.equalToSuperview().inset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.15)
            }
        } else {
            lightIntensityControl.snp.makeConstraints { make in
                make.top.equalTo(deviceDescriptionView.snp.bottom).offset(20)
                make.bottom.lessThanOrEqualToSuperview().inset(20)
                make.height.equalToSuperview().multipliedBy(0.5)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.3)
            }
        }
    }
    
    func handleDeviceOrientation() {
        if UIDevice.current.orientation.isLandscape {
            lightIntensityControl.snp.remakeConstraints { make in
                make.top.equalTo(deviceDescriptionView.snp.bottom).offset(20)
                make.bottom.equalToSuperview().inset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.15)
            }
        } else {
            lightIntensityControl.snp.remakeConstraints { make in
                make.top.equalTo(deviceDescriptionView.snp.bottom).offset(20)
                make.bottom.lessThanOrEqualToSuperview().inset(20)
                make.height.equalToSuperview().multipliedBy(0.5)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.3)
            }
        }
    }
}
