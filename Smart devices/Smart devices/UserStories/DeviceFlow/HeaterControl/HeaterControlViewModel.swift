//
//  HeaterControlViewModel.swift
//  Smart devices
//

import Foundation
import RxCocoa

protocol HeaterControlRouter: AnyObject {
    func closeHeaterControl()
}

final class HeaterControlViewModel {
    typealias Context = HasDevicesManager
    
    struct Input {
        let viewWillAppearSignal: Signal<Void>
        let didTapPowerButton: Signal<Void>
        let heaterTemperature: Signal<Decimal?>
        let didTapCloseButton: Signal<Void>
    }
    
    struct Output {
        let title: Driver<String>
        let heaterInitialValue: Driver<Decimal>
        let heaterValueDescription: Driver<String>
        let powerButtonIsSelected: Driver<Bool>
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

extension HeaterControlViewModel: ViewModelType {
    func transform(_ input: Input) -> Output {
        let heaterIsOn = BehaviorRelay(value: heaterInitialMode)
        
        let title = input.viewWillAppearSignal
            .map { [weak self] _ in self?.configuration.selectedDevice.deviceName }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let heaterInitialValue = input.viewWillAppearSignal
            .map { [weak self] _ in self?.heaterInitialTemperature }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let heaterValueDriver = input.heaterTemperature
            .asDriver(onErrorDriveWith: .never())
            .compactMap { $0 }
        
        let updateHeaterSignal = Driver
            .combineLatest(heaterIsOn.asDriver(), heaterValueDriver.debounce(.milliseconds(200)))
            .skip(1)
            .do(onNext: { [weak self] mode, temperature in
                self?.updateDevice(with: mode, and: temperature)
            })
            .map { _ in }
            .asSignal(onErrorSignalWith: .never())
        
        let heaterValueDescription = heaterValueDriver
            .map { L10n.HeaterControl.Description.temperature($0) }
                
        let powerButtonIsSelected = heaterIsOn.asDriver()
        
        let switchPowerButton = input.didTapPowerButton
            .do(onNext: { heaterIsOn.accept(!heaterIsOn.value) })
                
        let didTapCloseButton = input.didTapCloseButton
            .do(onNext: { [weak self] _ in self?.coordinatorRouter?.closeModal() })
                
        let pullcord = Signal.merge(
            updateHeaterSignal,
            switchPowerButton,
            didTapCloseButton
        )
                
        let output = Output(
            title: title,
            heaterInitialValue: heaterInitialValue,
            heaterValueDescription: heaterValueDescription,
            powerButtonIsSelected: powerButtonIsSelected,
            pullcord: pullcord
        )
        
        return output
    }
}
        
private extension HeaterControlViewModel {
    var heaterInitialTemperature: Decimal? {
        if case .heater(_, let temperature) = configuration.selectedDevice.deviceType {
            return temperature
        }
        return nil
    }
    
    var heaterInitialMode: Bool {
        if case .heater(let mode, _) = configuration.selectedDevice.deviceType {
            return mode
        }
        return false
    }
    
    func updateDevice(with mode: Bool, and temperature: Decimal) {
        guard case .heater = configuration.selectedDevice.deviceType else {
            return
        }
        
        let newDevice = Device(
            id: configuration.selectedDevice.id,
            deviceName: configuration.selectedDevice.deviceName,
            deviceType: .heater(mode: mode, temperature: temperature)
        )
        context.devicesManager.updateDevice(newDevice)
    }
}
