//
//  ConsoleControl.swift
//  ConsoleApp7
//
//  Created by Cedric Zwahlen on 21.05.21.
//

import Foundation


func clear() {
    
    let source =
"""

tell application "System Events"
    keystroke "l" using { command down }
end tell

"""
    
    let script = NSAppleScript(source: source)!
    
    _ = script.executeAndReturnError(nil)
    
}

func increaseWindowSize() {

    let source =
"""

tell application "System Events"
    key code 18 using { shift down, command down }
end tell



"""
    
    let script = NSAppleScript(source: source)!
    
    _ = script.executeAndReturnError(nil)
    
}

func decreaseWindowSize() {

    let source =
"""





"""
    
    let script = NSAppleScript(source: source)!
    
    _ = script.executeAndReturnError(nil)
    
}

func resizeWindow(width: Int, height: Int) {
    
    
    
    let i = Int(-2.88539 * ( logC(val: Double(max(height,width)), forBase: 2.71828)-6.93147 ) )
    
    let source =
"""

    tell application "Terminal"
        set bounds of front window to {20, 20, \(width * 10), \(height * 10)}
    end tell

    delay 1

    tell application "System Events"

        repeat \(i) times

            key code 78 using { command down }

        end repeat

    end tell

    delay 1
    
    tell application "Terminal"
        set bounds of front window to {20, 20, \(width * 3), \(height * 3)}
    end tell

"""
    
    let script = NSAppleScript(source: source)!
    
    _ = script.executeAndReturnError(nil)
    
    
}
