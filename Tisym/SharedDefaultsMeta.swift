//
//  SharedDefaultsMeta.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-09-29.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

class SharedDefaultsMeta {
    
    private var defaults = UserDefaults(suiteName: "group.barbat.hadrien.Tisym")!
    
    var lights: [Light] {
        get {
            let data = defaults.object(forKey: "lights") as? Data ?? Data()
            if let lights = try? JSONDecoder().decode([Light].self, from: data) {
                return lights
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: "lights")
                defaults.synchronize()
            }
        }
    }
    
    var bridgeIp: String? {
        get { return read("bridgeIp") as? String }
        set { write("bridgeIp", newValue) }
    }
    
    var hueUser: String? {
        get { return read("hueUser") as? String }
        set { write("hueUser", newValue) }
    }
    
    private func read(_ key: String) -> Any? {
        return defaults.value(forKey: key)
    }
    
    private func write(_ key: String, _ newValue: Any?) {
        defaults.set(newValue, forKey: key)
    }
    
    
}
