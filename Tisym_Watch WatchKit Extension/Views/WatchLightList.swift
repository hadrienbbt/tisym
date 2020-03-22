//
//  WatchLightList.swift
//  Tisym_Watch WatchKit Extension
//
//  Created by Hadrien Barbat on 2020-03-20.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct WatchLightList: View {
    @EnvironmentObject var hueDelegate: HueDelegate
    
    var body: some View {
        List {
            ForEach(hueDelegate.lights.indices, id: \.description) { i in
                LightRow(light: self.$hueDelegate.lights[i])
            }
        }
        .navigationBarTitle(Text("Lights"))
        .contextMenu(menuItems: {
            Button(action: {
                self.hueDelegate.userData.logout()
            }, label: {
                VStack {
                    Image(systemName: "person.icloud")
                        .font(.title)
                    Text("Logout")
                }
            })
        })
    }
}

struct WatchLightList_Previews: PreviewProvider {
    static var previews: some View {
        WatchLightList()
            .environmentObject(HueDelegate(userData: UserData()))
    }
}
