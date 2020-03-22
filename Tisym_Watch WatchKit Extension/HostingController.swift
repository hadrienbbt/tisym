//
//  HostingController.swift
//  Tisym_Watch WatchKit Extension
//
//  Created by Hadrien Barbat on 2020-03-20.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController : WKHostingController<MainView> {
    override var body: MainView {
        return MainView()
    }
}

struct MainView : View {
    let hueDelegate = HueDelegate()
    
    var body: some View {
        ContentView()
    }
}
