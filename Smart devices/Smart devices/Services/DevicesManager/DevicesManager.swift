//
//  DevicesManager.swift
//  Smart devices
//

import RxSwift
import Moya
import RxMoya
import RxRelay
import RxCocoa

protocol DevicesManagerProtocol {
    var devices: Driver<[Device]> { get }
    
    func loadDevicesFromServer() -> Single<Void>
    func updateDevice(_ device: Device)
}

final class DevicesManager {
    var devices: Driver<[Device]> {
        return allDevicesList.asDriver()
    }
    
    private let disposeBag = DisposeBag()
    private let allDevicesList = BehaviorRelay<[Device]>(value: [])
    private let moduloAPIProvider: MoyaProvider<ModuloAPI>
    
    init(moduloAPIProvider: MoyaProvider<ModuloAPI>) {
        self.moduloAPIProvider = moduloAPIProvider
    }
}

extension DevicesManager: DevicesManagerProtocol {
    func loadDevicesFromServer() -> Single<Void> {
        return moduloAPIProvider.rx.request(.loadAllDevices)
            .map(AllDevicesResponse.self)
            .do(onSuccess: { [weak allDevicesList] devicesResponse in
                allDevicesList?.accept(devicesResponse.devices)
            })
            .map { _ in }
    }
    
    func updateDevice(_ device: Device) {
        var allDevices = allDevicesList.value
        guard let index = allDevices.firstIndex(where: { $0.id == device.id }) else { return }
        allDevices[index] = device
        allDevicesList.accept(allDevices)
    }
}
