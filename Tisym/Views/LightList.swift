//
//  LightList.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-19.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct LightList: View {
    @EnvironmentObject var hueDelegate: HueDelegate
    
    var body: some View {
        NavigationView {
            List {
                ForEach(hueDelegate.lights.indices, id: \.description) { i in
                    LightRow(light: self.$hueDelegate.lights[i])
                        .environmentObject(self.hueDelegate)
                }
            }
            .navigationBarTitle(Text("Lights"))
            .listStyle(GroupedListStyle())
        }
    }
}

struct LightList_Previews: PreviewProvider {
    static var previews: some View {
        LightList()
            .environmentObject(HueDelegate(userData: UserData()))
    }
}
