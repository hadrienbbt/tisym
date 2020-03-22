//
//  LigthDetail.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-21.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct LigthDetail: View {
    @ObservedObject var hueDelegate: HueDelegate
    @Binding var light: Light
    @State var animating: Bool = false
    
    func toggleAnimation() {
        self.animating = !self.animating
    }
    
    func addLightness() {
        self.hueDelegate.setBrightness(to: light, light.brightness! + 20)
    }
    
    func reduceBrightness() {
         self.hueDelegate.setBrightness(to: light, light.brightness! - 20)
    }
    
    func red() {
        self.hueDelegate.setColor(to: light, red: 255, green: 0, blue: 0)
    }
    
    func blue() {
        self.hueDelegate.setColor(to: light, red: 0, green: 0, blue: 255)
    }
    
    func green() {
        self.hueDelegate.setColor(to: light, red: 0, green: 255, blue: 0)
    }
    
    var body: some View {
        List {
            Toggle(isOn: $light.isOn) {
                Text(light.name)
            }
            if light.isBulb() {
                #if os(watchOS)
                    Text("Stepper unavailable on WatchOS")
                #else
                    Stepper(onIncrement: self.addLightness, onDecrement: self.reduceBrightness) {
                        Text("Brightness")
                    }
                #endif
            }
            if light.isColor() {
                Button(action: { self.red() }) { Text("Red") }
                Button(action: { self.blue() }) { Text("Blue") }
                Button(action: { self.green() }) { Text("Green") }
            }
        }
        .navigationBarTitle(Text(light.name))
    }
}

struct LigthDetail_Previews: PreviewProvider {
    static var previews: some View {
        LigthDetail(hueDelegate: HueDelegate(), light: .constant(lightData[0]), animating: true)
    }
}
