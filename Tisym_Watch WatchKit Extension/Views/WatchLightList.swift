//
//  WatchLightList.swift
//  Tisym_Watch WatchKit Extension
//
//  Created by Hadrien Barbat on 2020-03-20.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct WatchLightList: View {
    @ObservedObject var hueDelegate: HueDelegate
    
    var body: some View {
        List {
            ForEach(hueDelegate.lights.indices) { i in
                LightRow(
                    hueDelegate: self.hueDelegate,
                    light: self.$hueDelegate.lights[i]
                )
            }
        }
        .navigationBarTitle(Text("Lights"))
        .contextMenu(menuItems: {
            ContextMenu(hueDelegate: self.hueDelegate)
        })
    }
}

struct WatchLightList_Previews: PreviewProvider {
    static var previews: some View {
        WatchLightList(hueDelegate: HueDelegate())
    }
}
