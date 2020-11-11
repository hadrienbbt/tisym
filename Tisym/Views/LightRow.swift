//
//  LightRow.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-19.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct LightRow: View {
    @ObservedObject var hueDelegate: HueDelegate
    @Binding var light: Light
    @State var rgbColour = RGB(r: 0, g: 1, b: 1)
    @State var brightness: CGFloat = 1
    
    var lastUpdate = Date()
    
    func red() {
        self.hueDelegate.setColor(to: light, red: 255, green: 0, blue: 0)
    }
    
    func blue() {
        self.hueDelegate.setColor(to: light, red: 0, green: 0, blue: 255)
    }
    
    func green() {
        self.hueDelegate.setColor(to: light, red: 0, green: 255, blue: 0)
    }
    
    var wheel: some View {
        ColourWheel(radius: 220, rgbColour: $rgbColour, brightness: $brightness)
            .padding()
    }
    
    var slider: some View {
        CustomSlider(rgbColour: $rgbColour, value: $brightness, range: 0.001...1)
            .padding()
    }
    
    var body: some View {
        let lightDetails = LigthDetail(
            hueDelegate: hueDelegate,
            light: $light
        )
        return NavigationLink(destination: lightDetails) {
            Toggle(isOn: $light.isOn) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(light.name)
                        .font(.headline)
                    if light.isBulb() && light.isColor() {
                        HStack {
                            Button(action: self.red) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Button(action: self.blue) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Button(action: self.green) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                        if #available(iOS 14.0, *) {
                            wheel.onChange(of: rgbColour) {
                                self.hueDelegate.setColor(to: light, rgbPercent: $0)
                            }
                            slider.onChange(of: brightness) {
                                self.hueDelegate.setBrightness(to: light, Int($0 * 255))
                            }
                        } else {
                            wheel
                            slider
                        }
                        
                    } else if light.isBulb() {
                        if #available(iOS 14.0, *) {
                            slider.onChange(of: brightness) {
                                self.hueDelegate.setBrightness(to: light, Int($0 * 255))
                            }
                        } else {
                            slider
                        }
                    }
                }
                .padding()
            }
        }
    }
}


struct LightRow_Previews: PreviewProvider {
    static var previews: some View {
        LightRow(
            hueDelegate: HueDelegate(),
            light: .constant(lightData[0])
        )
    }
}
