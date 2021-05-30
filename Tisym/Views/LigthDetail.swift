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
    @State private var currentColor = Colors(hex: colorHexData[0])
    
    @State var rgbColour = RGB(r: 0, g: 1, b: 1)
    @State var brightness: CGFloat = 1
    
    @State var wheelBrightness: CGFloat = 255
    
    var wheel: some View {
        ColourWheel(radius: 220, rgbColour: $rgbColour, brightness: $wheelBrightness)
            .padding()
    }
    
    var slider: some View {
        CustomSlider(rgbColour: $rgbColour, value: $brightness, range: 0.001...1)
            .padding()
    }
    
    let colorRange = colorHexData.map { Colors(hex: $0) }
    
    func addBrightness() {
        self.hueDelegate.setBrightness(to: light, light.brightness! + 20)
//        self.hueDelegate.donateIntent(with: true)
    }
    
    func reduceBrightness() {
        self.hueDelegate.setBrightness(to: light, light.brightness! - 20)
        self.hueDelegate.donateIntent()
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
    
    func getNextColor() -> Colors {
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
            if light.isOn {
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
    /*
                    Button(action: self.red) { Text("Red") }
                    Button(action: self.blue) { Text("Blue") }
                    Button(action: self.green) { Text("Green") }
                    Button(action: self.white) { Text("White") }
                    Button(action: self.black) { Text("Black") }
                    Button(action: self.equilab) { Text("Equilab") }
     */
                    Button(action: self.animating ? self.stopAnimation : self.startAnimation) {
                        Text(self.animating ? "Stop animation" : "Start animation")
                    }
                    if #available(iOS 14.0, *) {
                        wheel.onChange(of: rgbColour) {
                            self.hueDelegate.setColor(to: light, rgbPercent: $0)
                        }
                        /*
                        slider.onChange(of: brightness) {
                            self.hueDelegate.setBrightness(to: light, Int($0 * 255))
                        }
                        */
                    } else {
                        wheel
                        // slider
                    }
                } else if light.isBulb() {
                    /*
                    if #available(iOS 14.0, *) {
                        slider.onChange(of: brightness) {
                            self.hueDelegate.setBrightness(to: light, Int($0 * 255))
                        }
                    } else {
                        slider
                    }
                    */
                }
            }
        }
        .navigationBarTitle(Text(light.name))
        .onDisappear(perform: self.stopAnimation)
    }
}
