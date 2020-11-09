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
import Intents

class HueDelegate: ObservableObject {
        
    let sharedDefaultsMeta = SharedDefaultsMeta()
    
    @Published var bridgeIp: String? {
        willSet(newValue) { sharedDefaultsMeta.bridgeIp = newValue }
    }
    @Published var hueUser: String? {
        willSet(newValue) { sharedDefaultsMeta.hueUser = newValue }
    }
    
    @Published var lights = [Light]() {
        willSet {
            sharedDefaultsMeta.lights = newValue
            self.updateLights(lights: newValue)
        }
    }
    
    init() {
        bridgeIp = sharedDefaultsMeta.bridgeIp
        hueUser = sharedDefaultsMeta.hueUser
        fetchBridge()
    }
    
    init(_ completion: @escaping (Result<[Light], Error>) -> Void) {
        guard let bridgeIp = sharedDefaultsMeta.bridgeIp,
              let hueUser = sharedDefaultsMeta.hueUser else {
            completion(.failure(HueError("No user logged in")))
            return
        }
        self.bridgeIp = bridgeIp
        self.hueUser = hueUser
        getLights { result in
            switch(result) {
            case .success(let lights): completion(.success(lights))
            case .failure(let err): completion(.failure(err))
            }
        }
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
        sendToLight(light: light, message: ["bri": brightness]) { result in
            switch result {
            case .success(let result): print(result)
            case .failure(let err): print(HueError(err.localizedDescription))
            }
        }
        if let i = self.lights.firstIndex(where: { $0.id == light.id }) {
            self.lights[i].isOn = true
            self.lights[i].brightness = brightness
        }
    }
    
    func setColor(to light: Light, cie: CieColor) {
        if !light.isOn {
            sendToLight(light: light, message: ["on": true])
        }
        sendToLight(light: light, message: ["xy": [cie.x, cie.y]])
        if let i = self.lights.firstIndex(where: { $0.id == light.id }) {
            self.lights[i].isOn = true
            self.lights[i].cieColor = cie
        }
    }
    
    func setColor(to light: Light, red: Int, green: Int, blue: Int) {
        let cie = Colors.rgbToCie(red, green, blue)
        setColor(to: light, cie: cie)
    }
    
    func setColor(to light: Light, hex: String) {
        let cie = Colors.hexToCie(hex)
        setColor(to: light, cie: cie)
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
        getLights { result in
            switch(result) {
            case .success(let lights):
               DispatchQueue.main.async {
                   self.lights = lights
               }
            case .failure(let err): print(err)
            }
        }
    }
    
    func getLights(_ completion: @escaping (Result<[Light], Error>) -> Void) {
        let url = "http://\(bridgeIp!)/api/\(hueUser!)/lights"
        Utils.httpRequest(endpoint: url, method: .get, params: nil) { result in
            switch result {
            case .success(let dictLights):
                let lights = self.createLights(from: dictLights)
                completion(.success(lights))
            case .failure(let err): completion(.failure(err))
            }
        }
    }
    
    func donateIntent() {
        let intent = DimLightIntent()
        if #available(iOS 14.0, watchOSApplicationExtension 7.0, *) {
            intent.shortcutAvailability = .sleepWrapUpYourDay
        }
        intent.suggestedInvocationPhrase = "Dim the lights"
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Could not donate interaction", error)
                return
            }
            print("Successfully donated DimLightIntent interaction")
        }

    }
    
    func createLights(from lights: Dict) -> [Light] {
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
    
    func sendToLight(light: Light, message: Dict, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = "http://\(bridgeIp!)/api/\(hueUser!)/lights/\(light.id)/state"
        Utils.httpRequest(endpoint: url, method: .put, params: message) { completion($0) }
    }
    
    func sendToLight(light: Light, message: Dict) {
        let url = "http://\(bridgeIp!)/api/\(hueUser!)/lights/\(light.id)/state"
        Utils.httpRequest(endpoint: url, method: .put, params: message) { result in
            switch result {
                case .success(let res): print(res)
                case .failure(let err): print("Error: \(err)")
            }
        }
    }
}
