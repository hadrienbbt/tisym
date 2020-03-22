//
//  LightRow.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-19.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct LightRow: View {
    @Binding var light: Light
    @EnvironmentObject var hueDelegate: HueDelegate
    
    var body: some View {
        let lightDetails = LigthDetail(light: $light, animating: true)
            .environmentObject(self.hueDelegate)
        
        return NavigationLink(destination: lightDetails) {
            Toggle(isOn: $light.isOn) {
                Text(light.name)
            }
        }
    }
}


struct LightRow_Previews: PreviewProvider {
    
    static var previews: some View {
        LightRow(light: .constant(lightData[0]))
    }
}
