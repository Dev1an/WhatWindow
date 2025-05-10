//
//  ContentView.swift
//  WhatWindow
//
//  Created by Dufaux, Damiaan on 09/05/2025.
//

import SwiftUI

struct MasterDetail: View {
    let processes: [AppState.ProcessInfo]
    @State var selectedProcess: WindowManager.Process?
    
    var body: some View {
        NavigationSplitView {
            List(processes, id: \.process, selection: $selectedProcess) { process in
                Text(process.name ?? "PID: \(process.id)")
            }
        } detail: {
            if let process = selectedProcess, let windows = WindowManager.processes[process] {
                ProcessDetailView(process: process, windows: windows)
                    .navigationTitle((process.name ?? "Unknown") + " (PID: \(process.id))")
            } else {
                Text("Nothing selected")
            }
        }
    }
}

#Preview {
    MasterDetail(processes: {let s = AppState(); s.refresh(); return s.processes}())
}
