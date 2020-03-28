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
    
    var body: some View {
        let lightDetails = LigthDetail(
            hueDelegate: hueDelegate,
            light: $light
        )
        return NavigationLink(destination: lightDetails) {
            Toggle(isOn: $light.isOn) {
                Text(light.name)
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
