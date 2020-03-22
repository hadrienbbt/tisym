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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(hueDelegate.lights.indices, id: \.description) { i in
                    LightRow(
                        hueDelegate: self.hueDelegate,
                        light: self.$hueDelegate.lights[i]
                    )
                }
            }
            .navigationBarTitle(Text("Lights"))
            .navigationBarItems(trailing:
                Button("Logout") { self.hueDelegate.logout() }
            )
        }
    }
}

struct LightList_Previews: PreviewProvider {
    static var previews: some View {
        LightList(hueDelegate: HueDelegate())
    }
}
