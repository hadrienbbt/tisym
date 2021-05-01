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
    
    var body: some View {
        let lightDetails = LigthDetail(
            hueDelegate: hueDelegate,
            light: $light,
            rgbColour: Colors.cieToRGBPercent(light.cieColor ?? CieColor(x: 0, y: 0)),
            brightness: CGFloat(light.brightness ?? 255) / 255
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
