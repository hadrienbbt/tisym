//
//  UserData.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-19.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI
import Combine
import UIKit

struct UserData  {
    let valueStore = ValueStore()
    
    var hueUser: String? {
        willSet(newValue) {
            valueStore.hueUser = newValue
        }
    }
    
    var bridgeIp: String? {
        willSet(newValue) {
            valueStore.bridgeIp = newValue
        }
    }
    
    let deviceName = UIDevice.current.name
    
    init() {
        hueUser = valueStore.hueUser
        bridgeIp = valueStore.bridgeIp
    }
}
