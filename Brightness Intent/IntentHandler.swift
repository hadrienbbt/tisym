//
//  IntentHandler.swift
//  Brightness Intent
//
//  Created by Hadrien Barbat on 2020-09-28.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is DimLightIntent: return DimLightIntentHandler()
        default:
            print("Intent not supported \(intent.intentDescription ?? "no intent description")")
            return self
        }
    }
}

class DimLightIntentHandler: NSObject, DimLightIntentHandling {
    
    var hueDelegate: HueDelegate?
    var lights = SharedDefaultsMeta().lights
    
    func confirm(intent: DimLightIntent, completion: @escaping (DimLightIntentResponse) -> Void) {
        print("confirm intent")
        print(lights)
        self.hueDelegate = HueDelegate { result in
            switch result {
            case .success(let lights):
                print("Lights fetched")
                self.lights = lights
                completion(DimLightIntentResponse(code: .ready, userActivity: nil))
            case .failure(let err):
                print(err)
                completion(DimLightIntentResponse(code: .failure, userActivity: nil))
            }
        }
    }
    
    func handle(intent: DimLightIntent, completion: @escaping (DimLightIntentResponse) -> Void) {
        print("handle intent")
        let hueDelegate = HueDelegate()
        lights.forEach {
            if $0.isOn, let brightness = $0.brightness, brightness > 0 {
                hueDelegate.setBrightness(to: $0, brightness - 30)
            }
        }
        
        completion(DimLightIntentResponse(code: .success, userActivity: nil))
    }
}
