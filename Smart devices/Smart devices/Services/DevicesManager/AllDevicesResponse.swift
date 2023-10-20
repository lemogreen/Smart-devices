//
//  AllDevicesResponse.swift
//  Smart devices
//

import Foundation

struct AllDevicesResponse: Codable {
    let devices: [Device]
    
    private enum CodingKeys: String, CodingKey {
        case devices
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        devices = try container.decode([NilableDevice].self, forKey: .devices)
            .compactMap { $0.device }
    }
}

fileprivate struct NilableDevice: Codable {
    let device: Device?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AllDevicesKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let deviceName = try container.decode(String.self, forKey: .deviceName)
        let rawDeviceType = try container.decode(String.self, forKey: .productType)
        switch rawDeviceType {
        case "Heater":
            let mode = try container.decode(Device.Mode.self, forKey: .mode)
            let temperature = try container.decode(Decimal.self, forKey: .temperature)
            device = .init(
                id: id,
                deviceName: deviceName,
                deviceType: .heater(mode: mode.boolRepresentation, temperature: temperature)
            )
        case "Light":
            let mode = try container.decode(Device.Mode.self, forKey: .mode)
            let intensity = try container.decode(Int.self, forKey: .intensity)
            device = .init(
                id: id,
                deviceName: deviceName,
                deviceType: .light(mode: mode.boolRepresentation, intensity: intensity)
            )
        case "RollerShutter":
            let position = try container.decode(Int.self, forKey: .position)
            device = .init(
                id: id,
                deviceName: deviceName,
                deviceType: .rollerShutter(position: position)
            )
        default:
            device = nil
        }
    }
}

private extension NilableDevice {
    enum AllDevicesKeys: String, CodingKey {
        case id
        case deviceName
        case intensity
        case mode
        case productType
        case temperature
        case position
    }
}

private extension Device.Mode {
    var boolRepresentation: Bool {
        switch self {
        case .on:
            return true
        case .off:
            return false
        }
    }
}
