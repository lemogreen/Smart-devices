//
//  RollerShuttersViewModel.swift
//  Smart devices
//

import Foundation
import RxCocoa

protocol RollerShuttersRouter: AnyObject {
    func closeRollerShutterControl()
}

final class RollerShuttersViewModel {
    typealias Context = HasDevicesManager
    
    struct Input {
        let viewWillAppearSignal: Signal<Void>
        let rollerShutterPositionChanged: Signal<Int?>
        let didTapCloseButton: Signal<Void>
    }
    
    struct Output {
        let title: Driver<String>
        let rollerShutterPositionDescription: Driver<String>
        let rollerShutterInitialPosition: Driver<Int>
        let pullcord: Signal<Void>
    }
    
    struct Configuration {
        let selectedDevice: Device
    }
    
    weak var coordinatorRouter: DeviceControlRouter?
    
    private let context: Context
    private let configuration: Configuration
    
    init(context: Context, configuration: Configuration) {
        self.context = context
        self.configuration = configuration
    }
}

extension RollerShuttersViewModel: ViewModelType {
    func transform(_ input: Input) -> Output {
        let title = input.viewWillAppearSignal
            .map { [weak self] _ in self?.configuration.selectedDevice.deviceName }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let rollerShutterInitialPosition = input.viewWillAppearSignal
            .map { [weak self] _ in self?.rollerShutterInitialValue }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let rollerShutterPosition = input.rollerShutterPositionChanged.compactMap { $0 }
        
        let rollerShutterUpdatePositionSignal = rollerShutterPosition
            .skip(1)
            .debounce(.milliseconds(200))
            .do(onNext: { [weak self] intensityValue in self?.updateDevice(with: intensityValue) })
            .map { _ in }
        
        let rollerShutterPositionDescription = rollerShutterPosition
            .map { value -> String in
                if value == 0 { return L10n.RollerShuttersControl.Description.closed }
                if value == 100 { return L10n.RollerShuttersControl.Description.opened }
                return L10n.RollerShuttersControl.Description.openedAtPosition(value)
            }
            .asDriver(onErrorDriveWith: .never())
        
        let didTapCloseButton = input.didTapCloseButton
            .do(onNext: { [weak self] _ in self?.coordinatorRouter?.closeModal() })
        
        let pullcord = Signal.merge(
            rollerShutterUpdatePositionSignal,
            didTapCloseButton
        )
        
        let output = Output(
            title: title,
            rollerShutterPositionDescription: rollerShutterPositionDescription,
            rollerShutterInitialPosition: rollerShutterInitialPosition,
            pullcord: pullcord
        )
        
        return output
    }
}

private extension RollerShuttersViewModel {
    func updateDevice(with position: Int) {
        guard case .rollerShutter = configuration.selectedDevice.deviceType else {
            return
        }
        
        let newDevice = Device(
            id: configuration.selectedDevice.id,
            deviceName: configuration.selectedDevice.deviceName,
            deviceType: .rollerShutter(position: position)
        )
        context.devicesManager.updateDevice(newDevice)
    }
    
    var rollerShutterInitialValue: Int? {
        if case let .rollerShutter(position) = configuration.selectedDevice.deviceType {
            return position
        }
        return nil
    }
}
