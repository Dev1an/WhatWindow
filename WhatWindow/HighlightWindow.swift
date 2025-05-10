//
//  HighlightWindow.swift
//  WhatWindow
//
//  Created by Dufaux, Damiaan on 10/05/2025.
//

import SwiftUI

final class HighlightWindow: NSWindow {
    init(frame: NSRect) {
        super.init(
            contentRect: frame,
            styleMask: [.borderless],      // no titlebar, no resize controls
            backing: .buffered,
            defer: false
        )

        /* ────────── visual setup ────────── */
        backgroundColor      = .clear      // fully transparent
        isOpaque             = false
        hasShadow            = false

        /* ────────── z-order & behavior ────────── */
        level                = .statusBar  // always-on-top; use .screenSaver for “really” top
        collectionBehavior   = [
            .canJoinAllSpaces,             // show on every virtual desktop
            .fullScreenAuxiliary,          // also appear above full-screen apps
            .ignoresCycle                  // ⌘⇥ app switcher won’t land on it
        ]

        /* ────────── interaction ────────── */
        ignoresMouseEvents   = true        // overlay, not interactive

        isReleasedWhenClosed = false       // keep it around once created
        
        contentView = NSHostingView(rootView: Self.createHost())
        title = "Highlight window"
    }
    
    static func createHost() -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(style: .init(lineWidth: 2))
            .fill(.red)
            .padding(2)
            .allowedDynamicRange(.high)
    }
}
