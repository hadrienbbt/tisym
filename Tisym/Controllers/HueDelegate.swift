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
    @Published var userData: UserData
    
    init(userData: UserData) {
        loading = true
        self.userData = userData
        getBridgeIp { result in
            switch result {
            case .success():
                if self.userData.hueUser != nil {
                    self.userLoaded()
                }
            case .failure(let err): print("Error \(err)")
            }
        }
    }
    
    func getBridgeIp(_ completion: @escaping (Result<Void,Error>) -> Void) {
        if self.userData.bridgeIp != nil {
            completion(.success(()))
            return
        }
        Utils.httpRequest(endpoint: "https://discovery.meethue.com/", method: .get, params: nil) { result in
            switch result {
            case .success(let dict):
                if let ip = dict["internalipaddress"] as? String {
                    DispatchQueue.main.async {
                        self.userData.bridgeIp = ip
                        completion(.success(()))
                    }
                } else {
                    completion(.failure(HueError("Unable to find a bridge on the network")))
                }
            case .failure(let err): completion(.failure(err))
            }
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
    
    func createUser(_ completion: @escaping (Result<String,Error>) -> Void) {
        let url = "http://\(userData.bridgeIp!)/api"
        let params = ["devicetype": "Tisym#\(userData.deviceName)"]
        Utils.httpRequest(endpoint: url, method: .post, params: params) { result in
            switch result {
            case .success(let res):
                guard let success = res["success"] as? [String: Any],
                    let hueUser = success["username"] as? String
                else {
                    let error = HueError("Can't parse response to get username")
                    completion(.failure(error))
                    return
                }
                DispatchQueue.main.async {
                    self.userData.hueUser = hueUser
                    self.userLoaded()
                }
                completion(.success(hueUser))
            case .failure(let err):
                completion(Result.failure(err))
            }
        }
    }
    
    func userLoaded() {
        print("Current user loaded: \(userData.hueUser!)")
        getLights { lights in
            DispatchQueue.main.async {
                self.lights = self.createLights(from: lights)
                self.loading = false
            }
        }
    }
    
    func getLights(_ callback: @escaping ([String: Any]) -> Void) {
        let url = "http://\(userData.bridgeIp!)/api/\(userData.hueUser!)/lights"
        Utils.httpRequest(endpoint: url, method: .get, params: nil) { result in
            switch(result) {
            case .success(let dict):
                callback(dict)
            case .failure(let err):
                print(err)
                callback([:])
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
