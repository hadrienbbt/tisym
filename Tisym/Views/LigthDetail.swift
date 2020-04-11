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
    @State private var animating = false
    @State private var timer: Timer?
    @State private var currentColor = Color(hex: colorHexData[0])
    
    let colorRange = colorHexData.map { Color(hex: $0) }
    
    func addBrightness() {
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
    
    func white() {
        self.hueDelegate.setColor(to: light, hex: "#ffffff")
    }
    
    func black() {
        self.hueDelegate.setColor(to: light, hex: "#000000")
    }
    
    func equilab() {
        self.hueDelegate.setColor(to: light, hex: "#ED6C44")
    }
    
    func getNextColor() -> Color {
        if let i = colorRange.firstIndex(where: { $0.id == self.currentColor.id }) {
            if i == colorRange.count - 1 {
                return colorRange[0]
            } else {
                return colorRange[i + 1]
            }
        }
        return colorRange[0]
    }
    
    func startAnimation() {
        self.animating = true
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.currentColor = self.getNextColor()
            print("n° \(self.currentColor.id)")
            self.hueDelegate.setColor(to: self.light, red: self.currentColor.red, green: self.currentColor.green, blue: self.currentColor.blue)
        }
    }
    
    func stopAnimation() {
        self.animating = false
        self.timer?.invalidate()
    }
    
    var body: some View {
        List {
            Toggle(isOn: $light.isOn) {
                Text(light.name)
            }
            if light.isBulb() {
                #if os(watchOS)
                HStack {
                    Text("Brightness")
                    Spacer()
                    Button(action: self.reduceBrightness) {
                        Image(systemName: "minus")
                    }
                    Button(action: self.addBrightness) {
                        Image(systemName: "plus")
                    }
                }
                #else
                    Stepper(onIncrement: self.addBrightness, onDecrement: self.reduceBrightness) {
                        Text("Brightness")
                    }
                #endif
            }
            if light.isColor() {
                Button(action: self.red) { Text("Red") }
                Button(action: self.blue) { Text("Blue") }
                Button(action: self.green) { Text("Green") }
                Button(action: self.white) { Text("White") }
                Button(action: self.black) { Text("Black") }
                Button(action: self.equilab) { Text("Equilab") }
                Button(action: self.animating ? self.stopAnimation : self.startAnimation) {
                    Text(self.animating ? "Stop animation" : "Start animation")
                }
            }
        }
        .navigationBarTitle(Text(light.name))
        .onDisappear(perform: self.stopAnimation)
    }
}

struct LigthDetail_Previews: PreviewProvider {
    static var previews: some View {
        LigthDetail(hueDelegate: HueDelegate(), light: .constant(lightData[0]))
    }
}
