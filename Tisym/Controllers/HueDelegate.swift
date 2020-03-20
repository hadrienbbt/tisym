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
    
    private let ip = "192.168.1.14"
    
    var lastState = [String: Any]()
    @Published var lights = lightData
    @Published var loading = false
    @Published var userData: UserData
    
    init(userData: UserData) {
        self.userData = userData
        if self.userData.hueUser != nil {
            self.userLoaded()
        }
    }
    
    func createUser(_ completion: @escaping (Result<String,Error>) -> Void) {
        let url = URL(string: "http://\(ip)/api/")!
        let params = ["devicetype": "Tisym#\(userData.deviceName)"]
        Utils.httpRequest(endpoint: url, method: .post, params: params) { result in
            switch result {
            case .success(let res):
                if let error = res["error"] as? [String: Any],
                    let hueError: HueError = decode(json: error) {
                    completion(.failure(hueError))
                    return
                }
                guard let success = res["success"] as? [String: Any],
                    let hueUser = success["username"] as? String
                else {
                    print("Can't parse response to get username")
                    completion(.failure(HueError()))
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
        loading = true
        getState { lights in
            DispatchQueue.main.async {
                self.lights = self.createLights(from: lights)
                self.lights.forEach { light in
                    if light.name == "Bureau" {
                        self.toggleLight(light: light) { _ in
                            print(lights.description)
                        }
                    }
                }
                self.loading = false
                print(self.lights)
                print("Loading: \(self.loading)")
            }
        }
    }
    
    func getState(_ callback: @escaping ([String: Any]) -> Void) {
        let url = URL(string: "http://\(ip)/api/\(userData.hueUser!)/")!
        Utils.httpRequest(endpoint: url, method: .get, params: nil) { result in
            switch(result) {
            case .success(let dict):
                self.lastState = dict
                callback(dict)
            case .failure(let err):
                print(err)
                callback([:])
            }
            
        }
    }
    
    func createLights(from state: [String: Any]) -> [Light] {
        guard let lights = state["lights"] as? [String: Any] else { return [] }
        return lights.keys.reduce([]) {(result, key) in
            if let dict = lights[key] as? [String: Any], let light = Light.decode(id: key, dict: dict) {
                return result + [light]
            }
            return result
        }
    }
    
    func toggleLight(light: Light, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "http://\(ip)/api/\(userData.hueUser!))/lights/\(light.id)/state")!
        Utils.httpRequest(endpoint: url, method: .put, params: ["on": !light.isOn]) { result in
            switch result {
                case .success(let res):
                    print(res)
                    completion(true)
                case .failure(let err):
                    print(err)
                    completion(false)
            }
        }
    }
}
