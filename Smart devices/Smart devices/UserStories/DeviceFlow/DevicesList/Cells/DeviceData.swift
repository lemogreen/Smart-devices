//
//  DeviceData.swift
//  Smart devices
//

import RxDataSources

struct SectionOfDeviceData {
    var items: [Item]
}

extension SectionOfDeviceData: SectionModelType {
    typealias Item = Device
    
    init(original: SectionOfDeviceData, items: [Device]) {
        self = original
        self.items = items
    }
}
