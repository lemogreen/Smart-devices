//
//  Device.swift
//  Smart devices
//

import Foundation

struct Device: Codable {
    let id: Int
    let deviceName: String
    let deviceType: Device.DeviceType
    
    init(id: Int, deviceName: String, deviceType: Device.DeviceType) {
        self.id = id
        self.deviceName = deviceName
        self.deviceType = deviceType
    }
}

extension Device {
    enum DeviceType: Codable {
        case light(mode: Bool, intensity: Int)
        case heater(mode: Bool, temperature: Decimal)
        case rollerShutter(position: Int)
    }
    
    enum Mode: String, Codable {
        case on = "ON"
        case off = "OFF"
    }
}
