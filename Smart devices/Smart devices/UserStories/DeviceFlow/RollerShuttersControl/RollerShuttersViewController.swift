//
//  RollerShuttersViewController.swift
//  Smart devices
//

import UIKit
import RxCocoa
import RxSwift

final class RollerShuttersViewController: UIViewController {
    var viewModel: RollerShuttersViewModel!
    
    private let disposeBag = DisposeBag()
    
    private lazy var rollerShuttersControl = VerticalSliderControl()
    private lazy var deviceDescriptionView = DeviceDescriptionView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
}

extension RollerShuttersViewController: ViewModelBindable {
    func bind() {
        let viewWillAppearSignal = rx.viewWillAppear
            .take(1)
            .asSignal(onErrorSignalWith: .never())
            .map { _ in }
        
        let rollerShutterPositionChanged = rollerShuttersControl
            .rx
            .controlEvent(.valueChanged)
            .asSignal()
            .map { [weak rollerShuttersControl] _ in rollerShuttersControl?.value }

        let didTapCloseButton = deviceDescriptionView.rx.didTapCloseButton
        
        let input = ViewModel.Input(
            viewWillAppearSignal: viewWillAppearSignal,
            rollerShutterPositionChanged: rollerShutterPositionChanged,
            didTapCloseButton: didTapCloseButton
        )
        
        let output = viewModel.transform(input)
        
        output.title.drive(deviceDescriptionView.rx.deviceName).disposed(by: disposeBag)
        
        output.rollerShutterPositionDescription
            .drive(deviceDescriptionView.rx.deviceDescription)
            .disposed(by: disposeBag)
        
        output.rollerShutterInitialPosition
            .drive(rollerShuttersControl.rx.value)
            .disposed(by: disposeBag)
        
        output.pullcord.emit().disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.handleDeviceOrientation() })
            .disposed(by: disposeBag)
    }
}

private extension RollerShuttersViewController {
    func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(deviceDescriptionView)
        deviceDescriptionView.snp.makeConstraints { $0.top.left.right.equalToSuperview() }
        
        view.addSubview(rollerShuttersControl)
        makeRollerShutterControlConstraints()
        
        setupRollerShuttersControl()
    }
    
    func setupRollerShuttersControl() {
        rollerShuttersControl.backgroundColor = Asset
            .Colors
            .lightControlBackground
            .color
        
        rollerShuttersControl.scrollingIndicatorColor = Asset
            .Colors
            .lightControllScrollBackground
            .color
        
        rollerShuttersControl.iconTint = .systemGray6
        
        rollerShuttersControl.layer.cornerRadius = 30
        rollerShuttersControl.layer.masksToBounds = true
    }
    
    func makeRollerShutterControlConstraints() {
        if UIDevice.current.orientation.isLandscape {
            rollerShuttersControl.snp.makeConstraints { make in
                make.top.equalTo(deviceDescriptionView.snp.bottom).offset(20)
                make.bottom.equalToSuperview().inset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.15)
            }
        } else {
            rollerShuttersControl.snp.makeConstraints { make in
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
            rollerShuttersControl.snp.remakeConstraints { make in
                make.top.equalTo(deviceDescriptionView.snp.bottom).offset(20)
                make.bottom.equalToSuperview().inset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.15)
            }
        } else {
            rollerShuttersControl.snp.remakeConstraints { make in
                make.top.equalTo(deviceDescriptionView.snp.bottom).offset(20)
                make.bottom.lessThanOrEqualToSuperview().inset(20)
                make.height.equalToSuperview().multipliedBy(0.5)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.3)
            }
        }
    }
}
