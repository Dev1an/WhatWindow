//
//  ProcessDetailView.swift
//  WhatWindow
//
//  Created by Dufaux, Damiaan on 10/05/2025.
//

import SwiftUI

let highlightWindow = HighlightWindow(frame: .zero)

struct ProcessDetailView: View {
    let process: WindowManager.Process
    let windows: [WindowManager.Window]
    
    @State var selectedWindow: WindowManager.Window.ID?

    var body: some View {
        VSplitView {
            RectanglesView(
                objects: windows.reversed(),
                selection: $selectedWindow,
                rectangle: \.bounds
            ).padding()
            HSplitView {
                List(windows, selection: $selectedWindow) { window in
                    Text("\(window.name ?? "\(window.id)")")
                }
                VStack {
                    Group {
                        if let window = windows.first(where: {$0.id == selectedWindow}) {
                            WindowDetailView(process: process, window: window)
                        } else {
                            Text("No selection")
                        }
                    }
                    .padding()
                    Spacer(minLength: 0)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    struct WindowDetailView: View {
        let process: WindowManager.Process
        let window: WindowManager.Window
        
        @State var processInfo = ProcessInfo.none
    
        var body: some View {
            Grid(alignment: Alignment.leading) {
                GridRow {
                    Text("Process")
                        .bold()
                        .foregroundStyle(.secondary)
                        .gridCellColumns(2)
                        .padding(.bottom, 3)
                        .onAppear {
                            if let app = NSRunningApplication(processIdentifier: process.id) {
                                processInfo = .app(app)
                            } else if let url = getPidURL(pid: process.id) {
                                processInfo = .executable(url)
                            }
                        }
                }
                if let name = process.name {
                    GridRow {
                        if let icon = processInfo.app?.icon {
                            Image(nsImage: icon)
                        } else {
                            Text("Name:")
                        }
                        HStack {
                            Text(name).bold().textSelection(.enabled)
                            if let app = processInfo.app {
                                Button("Activate", systemImage: "arrowshape.right.circle") {
                                    app.activate()
                                }
                            }
                        }
                    }
                }
                GridRow {
                    Text("PID:")
                    Text("\(process.id)").textSelection(.enabled).bold()
                }
                switch processInfo {
                case .app(let app):
                    if let url = app.bundleURL?.path() {
                        GridRow {
                            Text("Bundle:")
                            Text(url).textSelection(.enabled).bold()
                        }
                    }
                    if let launch = app.launchDate {
                        GridRow {
                            Text("Launch date:")
                            Text("\(launch, format: .dateTime.day().month().year())")
                                .textSelection(.enabled).bold()
                        }
                        GridRow {
                            Text("Launch time:")
                            Text("\(launch, format: .dateTime.hour().minute().second().timeZone())")
                                .textSelection(.enabled).bold()
                        }
                    }
                case .executable(let url):
                    GridRow {
                        Text("Executable:")
                        Text(url.path()).textSelection(.enabled).bold()
                    }
                case .none:
                    EmptyView()
                }
                Divider()
                GridRow {
                    Text("Window")
                        .bold()
                        .foregroundStyle(.secondary)
                        .gridCellColumns(2)
                        .padding(.bottom, 3)
                }
                GridRow {
                    Text("ID:").gridColumnAlignment(.trailing)
                    HStack {
                        Text("\(window.id)")
                            .textSelection(.enabled)
                            .bold()
                        Button("Highlight", systemImage: "star") {
                            highlight(window: window)
                        }
                        .padding(.horizontal, 4)
                        Spacer()
                    }
                }
                if let name = window.name {
                    GridRow {
                        Text("Name:")
                        Text(name)
                            .bold()
                            .textSelection(.enabled)
                    }
                }
                GridRow {
                    Text("Layer:")
                    Text("\(window.layerNumber)")
                        .bold()
                        .textSelection(.enabled)
                }
                GridRow {
                    Text("Position:")
                    Text("\(window.bounds.origin)")
                        .bold()
                        .textSelection(.enabled)
                }
                GridRow {
                    Text("Size:")
                    Text("\(window.bounds.size)")
                        .bold()
                        .textSelection(.enabled)
                }
                GridRow {
                    Spacer().gridCellUnsizedAxes([.vertical, .horizontal])
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.tertiary)
                        .aspectRatio(window.bounds.size.width / window.bounds.size.height, contentMode: .fit)
                }
            }
        }
        
        func getPidURL(pid: pid_t) -> URL? {
            let pathBytes = [UInt8](unsafeUninitializedCapacity: Int(PROC_PIDPATHINFO_SIZE)) { buffer, initializedCount in
                
                if proc_pidpath(process.id, buffer.baseAddress!, UInt32(PROC_PIDPATHINFO_SIZE)) > 0 {
                    initializedCount = strlen(buffer.baseAddress!)
                } else {
                    print("Error")
                }
            }
            guard let path = String(data: Data(pathBytes), encoding: .utf8) else { return nil }
            return URL(fileURLWithPath: path)
        }
        
        func highlight(window: WindowManager.Window) {
            if let screen = highlightWindow.screen {
                highlightWindow.orderFront(self)
                highlightWindow.setFrame(
                    CGRect(origin: CGPoint(x: window.bounds.origin.x, y: screen.frame.height - window.bounds.maxY), size: window.bounds.size),
                    display: true
                )
                highlightWindow.alphaValue = 1
                Task {
                    try await Task.sleep(for: .seconds(1))
                    NSAnimationContext.runAnimationGroup { ctx in
                        ctx.duration = 2
                        highlightWindow.animator().alphaValue = 0
                    } completionHandler: {
                        if highlightWindow.alphaValue == 0 {
                            highlightWindow.orderOut(self)
                        }
                    }
                }
            }
        }
        
        enum ProcessInfo {
            case app(NSRunningApplication)
            case executable(URL)
            case none
            
            var app: NSRunningApplication? {
                if case .app(let app) = self {
                    app
                } else {
                    nil
                }
            }
        }
    }
}

#Preview {
    ProcessDetailView(
        process: .init(id: 1, name: "TextEdit"),
        windows: [
            .init(
                id: 1,
                bounds: CGRect(x: 582.0, y: 459.0, width: 646.0, height: 418.0),
                layerNumber: 1 as CFNumber,
                name: "Lorem"
            ),
            .init(
                id: 2,
                bounds: CGRect(x: 466.0, y: 343.0, width: 646.0, height: 418.0),
                layerNumber: 2 as CFNumber,
                name: "Ipsum"
            ),
        ],
        selectedWindow: 2
    )
}
