//
//  Light.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-17.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

struct Light: Hashable, Codable, Identifiable {
    
    let id: String
    let productId: String
    let name: String
    
    var isOn: Bool
    var isReachable: Bool
    var brightness: Int?
    
    init(_ id: String, _ productId: String, _ name: String, _ isOn: Bool, _ isReachable: Bool, _ brightness: Int?) {
        self.id = id
        self.productId = productId
        self.name = name
        self.isOn = isOn
        self.isReachable = isReachable
        self.brightness = brightness
    }
    
    static func decode(id: String, dict: [String: Any]) -> Light? {
        guard let productId = dict["productid"] as? String,
            let name = dict["name"] as? String,
            let state = dict["state"] as? [String: Any],
            let isOn = state["on"] as? Bool,
            let isReachable = state["reachable"] as? Bool
            else { return nil }
        var brightness: Int?
        if let bri = state["bri"] as? Int {
            brightness = bri
        }
        return Light(id, productId, name, isOn, isReachable, brightness)
    }
    
    var description: String {
        let isOnStr = isOn ? "on" : "off"
        return "\(name) is \(isOnStr). "
    }
}

