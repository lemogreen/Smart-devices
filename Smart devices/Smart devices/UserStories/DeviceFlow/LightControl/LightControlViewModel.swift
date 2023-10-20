//
//  LightControlViewModel.swift
//  Smart devices
//

import Foundation
import RxCocoa

protocol LightControlRouter: AnyObject {
    func closeLightControl()
}

final class LightControlViewModel {
    typealias Context = HasDevicesManager
    
    struct Input {
        let viewWillAppearSignal: Signal<Void>
        let lightIntensityControlValueChanged: Signal<Int?>
        let didTapCloseButton: Signal<Void>
    }
    
    struct Output {
        let title: Driver<String>
        let lightIntenistyDescriptionString: Driver<String>
        let lightControlInitialValue: Driver<Int>
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

extension LightControlViewModel: ViewModelType {
    func transform(_ input: Input) -> Output {
        let title = input.viewWillAppearSignal
            .map { [weak self] _ in self?.configuration.selectedDevice.deviceName }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let lightControlInitialValue = input.viewWillAppearSignal
            .map { [weak self] _ in self?.lightIntensityInitialValue }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let lightIntensityValue = input.lightIntensityControlValueChanged.compactMap { $0 }
        
        let updateLightIntensitySignal = lightIntensityValue
            .skip(1)
            .debounce(.milliseconds(200))
            .do(onNext: { [weak self] intensityValue in self?.updateDevice(with: intensityValue) })
            .map { _ in }
        
        let lightIntenistyDescriptionString = lightIntensityValue
            .map { $0 == 0
                ? L10n.LightControl.IntensityDescription.off
                : L10n.LightControl.IntensityDescription.intensity($0)
            }
            .asDriver(onErrorDriveWith: .never())
        
        let didTapCloseButton = input.didTapCloseButton
            .do(onNext: { [weak self] _ in self?.coordinatorRouter?.closeModal() })
        
        let pullcord = Signal.merge(updateLightIntensitySignal, didTapCloseButton)
        
        let output = Output(
            title: title,
            lightIntenistyDescriptionString: lightIntenistyDescriptionString,
            lightControlInitialValue: lightControlInitialValue,
            pullcord: pullcord
        )
        
        return output
    }
}

private extension LightControlViewModel {
    func updateDevice(with intensity: Int) {
        guard case .light = configuration.selectedDevice.deviceType else {
            return
        }
        
        let isOn = intensity != 0
        
        let newDevice = Device(
            id: configuration.selectedDevice.id,
            deviceName: configuration.selectedDevice.deviceName,
            deviceType: .light(mode: isOn, intensity: intensity)
        )
        context.devicesManager.updateDevice(newDevice)
    }
    
    var lightIntensityInitialValue: Int? {
        if case .light(_, let intensity) = configuration.selectedDevice.deviceType {
            return intensity
        }
        return nil
    }
}
