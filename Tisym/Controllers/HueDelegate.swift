//
//  HueDelegate.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-17.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

class HueDelegate: ObservableObject {
    
    private let ip = "192.168.1.14"
    private let user = "6lsbVI1gkOIshhJlcekxA-tisfEwbEP3K2kG5RTU"
    
    var lastState = [String: Any]()
    @Published var lights = lightData
    @Published var loading = false
        
    init() {
        print("Loading: \(self.loading)")
        getState { lights in
            DispatchQueue.main.async {
                self.lights = self.createLights(from: lights)
                self.loading = false
                print(self.lights)
                print("Loading: \(self.loading)")
            }
        }
    }
    
    func getState(_ callback: @escaping ([String: Any]) -> Void) {
        let url = URL(string: "http://\(ip)/api/\(user)/")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data,
                let string = String(data: data, encoding: .utf8),
                let dict = Utils.convertToDictionary(text: string)
                else {
                    callback([:])
                    return
            }
            self.lastState = dict
            callback(dict)
        }
        task.resume()
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
        let url = URL(string: "http://\(ip)/api/\(user))/lights/\(light.id)/state")!
        Utils.postRequest(endpoint: url, params: ["on": !light.isOn]) { result in
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
