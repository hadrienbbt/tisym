//
//  LightList.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-19.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct LightList: View {
    @ObservedObject var hueDelegate: HueDelegate
    
    func createColorBulbRow(_ light: Light) -> LightRow {
        let index = self.hueDelegate.lights.firstIndex(of: light)!
        return LightRow(
            hueDelegate: self.hueDelegate,
            light: self.$hueDelegate.lights[index],
            rgbColour: Colors.cieToRGBPercent(light.cieColor ?? CieColor(x: 0, y: 0)),
            brightness: CGFloat(light.brightness ?? 255) / 255
        )
    }
    
    func createWhiteBulbRow(_ light: Light) -> LightRow {
        let index = self.hueDelegate.lights.firstIndex(of: light)!
        return LightRow(
            hueDelegate: self.hueDelegate,
            light: self.$hueDelegate.lights[index],
            brightness: CGFloat(light.brightness ?? 255) / 255
        )
    }
    
    func createSmartPlugRow(_ light: Light) -> LightRow {
        let index = self.hueDelegate.lights.firstIndex(of: light)!
        return LightRow(
            hueDelegate: self.hueDelegate,
            light: self.$hueDelegate.lights[index]
        )
    }
    
    var list: some View {
        let sortedLights = hueDelegate.lights.sorted(by: { $0.name < $1.name })
        let coloredBulbs = sortedLights.filter { $0.isBulb() && $0.isColor() }
        let whiteBulbs = sortedLights.filter { $0.isBulb() && !$0.isColor() }
        let smartPlugs = sortedLights.filter { !$0.isBulb() && !$0.isColor() }
        
        return NavigationView {
            List {
                Section(header: Text("Color Bulbs")) {
                    ForEach(coloredBulbs) { self.createColorBulbRow($0) }
                }
                Section(header: Text("White Ambiance Bulbs")) {
                    ForEach(whiteBulbs) { self.createWhiteBulbRow($0) }
                }
                Section(header: Text("Smart Plugs")) {
                    ForEach(smartPlugs) { self.createSmartPlugRow($0) }
                }
            }
            .navigationBarTitle(Text("Lights"))
            .navigationBarItems(trailing:
                Button("Logout") { self.hueDelegate.logout() }
            )
        }
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            list.listStyle(InsetGroupedListStyle())
        } else {
            list
        }
    }
}

struct LightList_Previews: PreviewProvider {
    static var previews: some View {
        LightList(hueDelegate: HueDelegate())
    }
}
