//
//  ContentView.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-17.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var hueDelegate: HueDelegate
    
    @ViewBuilder
    var body: some View {
        if hueDelegate.bridgeIp == nil {
            NoBridge(hueDelegate: hueDelegate)
        } else if hueDelegate.hueUser == nil {
            LoginHue(hueDelegate: hueDelegate)
        } else {
            #if os(watchOS)
                WatchLightList(hueDelegate: hueDelegate)
            #else
                LightList(hueDelegate: hueDelegate)
            #endif
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(hueDelegate: HueDelegate())
    }
}
