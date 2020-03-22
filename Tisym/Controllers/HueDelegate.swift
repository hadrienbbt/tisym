//
//  HueDelegate.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-17.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation
import Combine
import UIKit

class HueDelegate: ObservableObject {
        
    let valueStore = ValueStore()
    
    @Published var bridgeIp: String? {
        willSet(newValue) { valueStore.bridgeIp = newValue }
    }
    @Published var hueUser: String? {
        willSet(newValue) { valueStore.hueUser = newValue }
    }
    
    @Published var lights = [Light]() {
        willSet {
            self.updateLights(lights: newValue)
        }
    }
    
    init() {
        bridgeIp = valueStore.bridgeIp
        hueUser = valueStore.hueUser
        fetchBridge()
    }
    
    func logout() {
        bridgeIp = nil
        hueUser = nil
        fetchBridge()
    }
    
    func setBrightness(to light: Light, _ brightness: Int) {
        if brightness < 0 {
            setBrightness(to: light, 0)
            return
        }
        if brightness > 254 {
            setBrightness(to: light, 254)
            return
        }
        if !light.isOn {
            sendToLight(light: light, message: ["on": true])
        }
        sendToLight(light: light, message: ["bri": brightness])
        if let i = self.lights.firstIndex(where: { $0.id == light.id }) {
            self.lights[i].isOn = true
            self.lights[i].brightness = brightness
        }
    }
    
    func setColor(to light: Light, x: Float, y: Float) {
        sendToLight(light: light, message: ["xy": [x, y], "colormode": "xy"])
    }
    
    func setColor(to light: Light, red: Double, green: Double, blue: Double) {
        let cie = Utils.rgbToCie(red, green, blue)
        sendToLight(light: light, message: ["xy": cie, "colormode": "xy"])
    }
    
    func fetchBridge() {
        if self.bridgeIp != nil {
            self.onBridgeFound()
            return
        }
        Utils.httpRequest(endpoint: "https://discovery.meethue.com/", method: .get, params: nil) { result in
            switch result {
            case .success(let dict):
                if let ip = dict["internalipaddress"] as? String {
                    DispatchQueue.main.async {
                        self.bridgeIp = ip
                        self.onBridgeFound()
                    }
                } else {
                    print(HueError("Unable to find a bridge on the network"))
                }
            case .failure(let err): print("Error \(err)")
            }
        }
    }
    
    func onBridgeFound() {
        print("Bridge foud: \(self.bridgeIp!)")
        if self.hueUser != nil {
            self.userLoaded()
        }
    }
    
    func updateLights(lights: [Light]) {
        self.lights.forEach { light in
            if let newLight = lights.first(where: { $0.id == light.id }) {
                if newLight.isOn != light.isOn {
                    sendToLight(light: newLight, message: ["on": newLight.isOn])
                }
            }
        }
    }
    
    func createUser() {
        let url = "http://\(bridgeIp!)/api"
        let params = ["devicetype": "Tisym#\(UserData().deviceName)"]
        Utils.httpRequest(endpoint: url, method: .post, params: params) { result in
            switch result {
            case .success(let res):
                guard let success = res["success"] as? [String: Any],
                    let hueUser = success["username"] as? String
                else {
                    print(HueError("Can't parse response to get username"))
                    return
                }
                DispatchQueue.main.async {
                    self.hueUser = hueUser
                    self.userLoaded()
                }
            case .failure(let err): print(err)
            }
        }
    }
        
    func userLoaded() {
        print("Current user loaded: \(hueUser!)")
        getLights()
    }
    
    func getLights() {
        let url = "http://\(bridgeIp!)/api/\(hueUser!)/lights"
        Utils.httpRequest(endpoint: url, method: .get, params: nil) { result in
            switch(result) {
            case .success(let lights):
                DispatchQueue.main.async {
                    self.lights = self.createLights(from: lights)
                }
            case .failure(let err): print(err)
            }
            
        }
    }
    
    func createLights(from lights: [String: Any]) -> [Light] {
        return lights.keys.reduce([]) {(result, key) in
            if let dict = lights[key] as? [String: Any], let light = Light.decode(id: key, dict: dict) {
                return result + [light]
            }
            return result
        }
    }
    
    func toggleLight(light: Light) -> String {
        sendToLight(light: light, message: ["on": !light.isOn])
        return light.description
    }
    
    func sendToLight(light: Light, message: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = "http://\(bridgeIp!)/api/\(hueUser!)/lights/\(light.id)/state"
        Utils.httpRequest(endpoint: url, method: .put, params: message) { completion($0) }
    }
    
    func sendToLight(light: Light, message: [String: Any]) {
        let url = "http://\(bridgeIp!)/api/\(hueUser!)/lights/\(light.id)/state"
        Utils.httpRequest(endpoint: url, method: .put, params: message) { result in
            switch result {
                case .success(let res): print(res)
                case .failure(let err): print("Error: \(err)")
            }
        }
    }
}
