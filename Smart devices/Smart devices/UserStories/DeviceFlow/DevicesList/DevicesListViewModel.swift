//
//  DevicesListViewModel.swift
//  Smart devices
//

import RxSwift
import RxCocoa
import Foundation

protocol DevicesListCoordinatorRouter: AnyObject {
    func openDeviceDetailsPage(device: Device)
}

final class DevicesListViewModel {
    typealias DevicesListViewModelContext = HasDevicesManager
    
    struct Input {
        let viewWillAppearSignal: Signal<Void>
        let refreshControlValueChanged: Signal<Void>
        let deviceToUpdateIndexPath: Signal<IndexPath?>
        let didSelectCell: Signal<IndexPath>
    }
    
    struct Output {
        let cells: Driver<[SectionOfDeviceData]>
        let deviceUpdatedSignal: Signal<Void>
        let pullcord: Signal<Void>
    }
    
    weak var coordinatorRouter: DevicesListCoordinatorRouter?
    
    private let context: DevicesListViewModelContext
    
    init(context: DevicesListViewModelContext) {
        self.context = context
    }
}

extension DevicesListViewModel: ViewModelType {
    func transform(_ input: Input) -> Output {
        let devicesSignal = context.devicesManager.devices.asSignal(onErrorSignalWith: .never())
        
        let openHeaterControl = input.didSelectCell
            .withLatestFrom(devicesSignal, resultSelector: { $1[$0.row] })
            .do(onNext: { [weak coordinatorRouter] selectedDevice in
                coordinatorRouter?.openDeviceDetailsPage(device: selectedDevice)
            })
            .map { _ in }
            .asSignal()
        
        let shouldLoadListOfDevices = Signal<Void>
            .merge(
                input.viewWillAppearSignal,
                input.refreshControlValueChanged
            )
        
        let loadDevicesFromServerSignal = shouldLoadListOfDevices
            .flatMapLatest { [weak self] in
                self?.context.devicesManager.loadDevicesFromServer()
                    .asSignal(onErrorSignalWith: .never()) ?? .never()
            }
        
        let deviceUpdatedSignal = input.deviceToUpdateIndexPath
            .compactMap { $0 }
            .withLatestFrom(devicesSignal, resultSelector: { $1[$0.row] })
            .do(onNext: { [weak self]  device in self?.changeDeviceMode(on: device) })
            .map { _ in }
        
        let pullcord = Signal.merge(
            openHeaterControl,
            loadDevicesFromServerSignal
        )
        
        let cells = context.devicesManager.devices.map { [SectionOfDeviceData(items: $0)] }
        
        let output = Output(
            cells: cells,
            deviceUpdatedSignal: deviceUpdatedSignal,
            pullcord: pullcord
        )
        
        return output
    }
}

private extension DevicesListViewModel {
    func changeDeviceMode(on device: Device) {
        var deviceTypeWithChangedMode: Device.DeviceType
        switch device.deviceType {
        case let .light(mode, intensity):
            deviceTypeWithChangedMode = .light(mode: !mode, intensity: intensity)
        case let .heater(mode, temperature):
            deviceTypeWithChangedMode = .heater(mode: !mode, temperature: temperature)
        case .rollerShutter:
            deviceTypeWithChangedMode = device.deviceType
        }
        let newDevice = Device(
            id: device.id,
            deviceName: device.deviceName,
            deviceType: deviceTypeWithChangedMode
        )
        
        context.devicesManager.updateDevice(newDevice)
    }
}
