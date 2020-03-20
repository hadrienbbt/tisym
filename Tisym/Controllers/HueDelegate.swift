//
//  HueDelegate.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-17.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation
import Combine

class HueDelegate: ObservableObject {
        
    @Published var lights = [Light]() {
        willSet {
            self.updateLights(lights: newValue)
        }
    }
    @Published var loading = false
    @Published var userData: UserData {
        didSet {
            if self.userData.bridgeIp == nil {
                fetchBridge()
            }
        }
    }
    
    init(userData: UserData) {
        loading = true
        self.userData = userData
        fetchBridge()
    }
    
    func fetchBridge() {
        if self.userData.bridgeIp != nil {
            self.onBridgeFound()
            return
        }
        Utils.httpRequest(endpoint: "https://discovery.meethue.com/", method: .get, params: nil) { result in
            switch result {
            case .success(let dict):
                if let ip = dict["internalipaddress"] as? String {
                    DispatchQueue.main.async {
                        self.userData.bridgeIp = ip
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
        print("Bridge foud: \(self.userData.bridgeIp!)")
        if self.userData.hueUser != nil {
            self.userLoaded()
        }
    }
    
    func updateLights(lights: [Light]) {
        self.lights.forEach { light in
            if let newLight = lights.first(where: { $0.id == light.id }) {
                if newLight.isOn != light.isOn {
                    sendToLight(light: newLight, message: ["on": newLight.isOn]) { _ in }
                }
            }
        }
    }
    
    func createUser() {
        let url = "http://\(userData.bridgeIp!)/api"
        let params = ["devicetype": "Tisym#\(userData.deviceName)"]
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
                    self.userData.hueUser = hueUser
                    self.userLoaded()
                }
            case .failure(let err): print(err)
            }
        }
    }
        
    func userLoaded() {
        print("Current user loaded: \(userData.hueUser!)")
        getLights()
    }
    
    func getLights() {
        let url = "http://\(userData.bridgeIp!)/api/\(userData.hueUser!)/lights"
        Utils.httpRequest(endpoint: url, method: .get, params: nil) { result in
            switch(result) {
            case .success(let lights):
                DispatchQueue.main.async {
                    self.lights = self.createLights(from: lights)
                    self.loading = false
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
        sendToLight(light: light, message: ["on": !light.isOn]) { result in
            switch result {
                case .success(let res): print(res)
                case .failure(let err): print("Error: \(err)")
            }
        }
        return light.description
    }
    
    func sendToLight(light: Light, message: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = "http://\(userData.bridgeIp!)/api/\(userData.hueUser!)/lights/\(light.id)/state"
        Utils.httpRequest(endpoint: url, method: .put, params: message) { completion($0) }
    }
}
