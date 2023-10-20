//
//  Context.swift
//  Smart devices
//

import Foundation

final class Context: HasDevicesManager {
    let devicesManager: DevicesManagerProtocol
    
    init(devicesManager: DevicesManagerProtocol) {
        self.devicesManager = devicesManager
    }
}

protocol HasDevicesManager {
    var devicesManager: DevicesManagerProtocol { get }
}
