//
//  WhatWindowApp.swift
//  WhatWindow
//
//  Created by Dufaux, Damiaan on 09/05/2025.
//

import SwiftUI

@main
struct WhatWindowApp: App {
    @State var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MasterDetail(processes: appState.processes)
                .onAppear(perform: appState.refresh)
                .toolbar {
                    Button("Refresh", systemImage: "arrow.counterclockwise") {
                        withAnimation(.default, appState.refresh)
                    }
                }
        }.commands {
            CommandGroup(before: .toolbar) {
                Button("Refresh"){
                    withAnimation(.default, appState.refresh)
                }.keyboardShortcut(.init("r"))
            }
        }
    }
}

@Observable class AppState {
    var processes = [ProcessInfo]()
    
    func refresh() {
        processes = WindowManager.processes.sorted(by: { left, right in
            guard let leftName = left.key.name, let rightName = right.key.name else {
                return left.key.id < right.key.id
            }
            return leftName < rightName
        }).map {
            ProcessInfo(process: $0, windows: $1)
        }
    }
    
    struct ProcessInfo: Identifiable {
        let process: WindowManager.Process
        let windows: [WindowManager.Window]
        
        var id: pid_t { process.id }
        var name: String? { process.name }
    }
}
