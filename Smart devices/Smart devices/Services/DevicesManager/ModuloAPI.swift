//
//  ModuloAPI.swift
//  Smart devices
//

import Foundation
import Moya

enum ModuloAPI {
    case loadAllDevices
}

extension ModuloAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "http://storage42.com/modulotest") else {
            fatalError()
        }
        return url
    }
    
    var path: String {
        switch self {
        case .loadAllDevices:
            return "data.json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .loadAllDevices:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .loadAllDevices:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
