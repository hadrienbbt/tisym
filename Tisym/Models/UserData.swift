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

struct UserData {
    
    #if os(iOS)
    let deviceName = UIDevice.current.name
    #endif
    #if os(watchOS)
    let deviceName = "Watch"
    #endif
    
}
