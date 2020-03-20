//
//  ContentView.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-17.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var hueDelegate: HueDelegate
    
    @ViewBuilder
    var body: some View {
        if hueDelegate.userData.hueUser != nil {
            LightList()
                .environmentObject(hueDelegate)
        } else {
            LoginHue()
                .environmentObject(hueDelegate)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var hueDelegate = HueDelegate(userData: UserData())
    
    static var previews: some View {
        ContentView()
            .environmentObject(hueDelegate)
    }
}
