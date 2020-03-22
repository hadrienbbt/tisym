//
//  ContextMenu.swift
//  Tisym_Watch WatchKit Extension
//
//  Created by Hadrien Barbat on 2020-03-20.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct ContextMenu: View {
    @EnvironmentObject var hueDelegate: HueDelegate
    
    var body: some View {
        Button(action: {
            self.hueDelegate.logout()
        }, label: {
            VStack {
                Image(systemName: "person.icloud")
                    .font(.title)
                Text("Logout")
            }
        })
    }
}
