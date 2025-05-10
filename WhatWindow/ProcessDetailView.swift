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
                            WindowDetailView(window: window)
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
        let window: WindowManager.Window
    
        var body: some View {
            Grid(alignment: Alignment.leading) {
                GridRow {
                    Text("ID:").gridColumnAlignment(.trailing)
                    HStack {
                        Text("\(window.id)")
                            .textSelection(.enabled)
                            .bold()
                        Button("Highlight") {
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
