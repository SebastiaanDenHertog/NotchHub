//
//  NotchHubApp.swift
//  NotchHub
//
//  Created by Sebastiaan den Hertog on 10/02/2025.
//

import Cocoa
import SwiftUI
import os

class NotchHubApp: NSObject, NSApplicationDelegate {
    
    var overlayWindow: NSWindow?
    var settingsWindow: NSWindow?

    var mouseMoveMonitor: Any?
    var mouseDownMonitor: Any?
    
    let logger = Logger()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        createOverlayWindow()
        startMonitoringMouseMove()
        startMonitoringMouseDown()
    }
    
    private func createOverlayWindow() {
        guard let screen = NSScreen.main else { return }

        let overlayWidth: CGFloat = 250
        let overlayHeight: CGFloat = 74
        let visibleFrame = screen.visibleFrame

        let xPos = visibleFrame.midX - (overlayWidth / 2)
        let yPos = visibleFrame.maxY - overlayHeight

        let frame = NSRect(x: xPos, y: yPos, width: overlayWidth, height: overlayHeight)

        // Create a borderless floating window
        let window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        
        // Embed your SwiftUI overlay
        let hostingView = NSHostingView(rootView: ContentView {
            // The gear button was tapped -> show settings
            self.showSettingsWindow()
        })
        hostingView.frame = NSRect(x: 0, y: 0, width: overlayWidth, height: overlayHeight)
        
        window.contentView = hostingView
        
        // For debugging, let's show it immediately
        window.makeKeyAndOrderFront(nil)
        
        self.overlayWindow = window
    }
    
    // MARK: - Showing the Settings Window
    
    func showSettingsWindow() {
        // If we already have a settings window, bring it forward
        if let settingsWindow = settingsWindow {
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // Otherwise, create one
        let newSettingsWindow = NSWindow(
              contentRect: NSRect(x: 200, y: 200, width: 400, height: 300),
              styleMask: [.titled, .closable, .resizable], // no .miniaturizable if you don't want the minimize button
              backing: .buffered,
              defer: false
          )
        newSettingsWindow.title = "NotchHub Settings"

        // Embed SwiftUI settings
        let hostingView = NSHostingView(rootView: SettingsView {
            // The user tapped "Close" in the settings
            newSettingsWindow.close()
        })
        
        newSettingsWindow.contentView = hostingView
        self.settingsWindow = newSettingsWindow

        // Show it
        newSettingsWindow.center()
        newSettingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Mouse Move Monitoring
    
    private func startMonitoringMouseMove() {
        mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.handleMouseMoved()
        }
    }
    
    private func handleMouseMoved() {
        guard let screen = NSScreen.main,
              let overlayWindow = overlayWindow else
        {
            print("return")
            return
        }
        
        let mouseLocation = NSEvent.mouseLocation
        logger.debug("Mouse location: X: \(mouseLocation.x, privacy: .public) Y: \(mouseLocation.y, privacy: .public)")
        
        // Example threshold logic:
        let thresholdY: CGFloat = 200
        let thresholdX: CGFloat = 50
        
        let maxX = screen.visibleFrame.maxX
        let maxY = screen.visibleFrame.maxY
        
        let isNearTopCenter = (
            mouseLocation.y > (maxY - thresholdY) &&
            mouseLocation.x < (maxX / 2 + thresholdX) &&
            mouseLocation.x > (maxX / 2 - thresholdX)
        )
        
        if isNearTopCenter {
            if !overlayWindow.isVisible {
                overlayWindow.orderFront(nil)
            }
        } else {
            if overlayWindow.isVisible {
                overlayWindow.orderOut(nil)
            }
        }
    }
    
    // MARK: - Mouse Down Monitoring
    
    private func startMonitoringMouseDown() {
        mouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        ) { [weak self] event in
            self?.handleMouseDown()
        }
    }
    
    private func handleMouseDown() {
        guard let overlayWindow = overlayWindow,
              overlayWindow.isVisible else { return }
        
        let clickLocation = NSEvent.mouseLocation
        let overlayFrame = overlayWindow.frame
        
        if !overlayFrame.contains(clickLocation) {
            overlayWindow.orderOut(nil)
        }
    }
    
    // MARK: - Cleanup
    
    func applicationWillTerminate(_ notification: Notification) {
        removeMonitors()
    }
    
    private func removeMonitors() {
        if let mouseMoveMonitor = mouseMoveMonitor {
            NSEvent.removeMonitor(mouseMoveMonitor)
            self.mouseMoveMonitor = nil
        }
        if let mouseDownMonitor = mouseDownMonitor {
            NSEvent.removeMonitor(mouseDownMonitor)
            self.mouseDownMonitor = nil
        }
    }
    
    // MARK: - Quit
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
