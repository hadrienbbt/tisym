//
//  HueDevice.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-22.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

enum HueProductName: String, Decodable, Encodable {
    case smartPlug = "Hue Smart Plug"
    case ambiance = "Hue ambiance lamp"
    case color = "Hue color lamp"
    case unknown = "Unknown"
}

protocol HueDevice: Hashable, Codable, Identifiable {
    var id: String { get }
    var productId: String { get }
    var name: String { get }
    var productName: HueProductName { get }
    
    var isOn: Bool { get set }
    var isReachable: Bool { get set }
}

extension HueDevice {
    static public func getProductName(from state: [String: Any]) -> HueProductName {
        guard let val = state["productname"] as? String,
            let productName = HueProductName(rawValue: val)
        else {
            return .unknown
        }
        return productName
    }
    
    func isBulb() -> Bool {
        return self.productName == .ambiance || self.productName == .color
    }
    
    func isColor() -> Bool {
        return self.productName == .color
    }
}
/*
extension Dict {
    func decode() -> Self? {
        let productName = HueDevice.getProductName(from: self)
        switch productName {
        case .color:
            return Light.decode(id: id, dict: dict)
        default:
            return Light.decode(id: id, dict: dict)
        }
    }
}
 */
