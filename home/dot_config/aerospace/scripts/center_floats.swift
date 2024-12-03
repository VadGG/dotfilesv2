import AppKit

// Function to parse arguments
func parseArguments() -> (width: CGFloat, height: CGFloat) {
    guard let mainScreen = NSScreen.main else {
        return (width: 1600, height: 900)  // fallback default
    }

    let screenFrame = mainScreen.visibleFrame
    var width = screenFrame.width * 0.7
    var height = screenFrame.height * 0.9

    let args = CommandLine.arguments
    for (index, arg) in args.enumerated() {
        switch arg {
        case "-w":
            if index + 1 < args.count, let w = Double(args[index + 1]) {
                width = CGFloat(w)
            }
        case "-h":
            if index + 1 < args.count, let h = Double(args[index + 1]) {
                height = CGFloat(h)
            }
        default:
            break
        }
    }

    return (width: width, height: height)
}

// Parse command-line arguments
let (desiredWidth, desiredHeight) = parseArguments()

// Function to run a shell command
@discardableResult
func runShellCommand(_ command: String) -> Int32 {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")  // Change to /bin/bash if using bash
    process.arguments = ["-c", command]
    process.launch()
    process.waitUntilExit()
    return process.terminationStatus
}

// Function to get the frontmost window
func getFrontmostWindow() -> AXUIElement? {
    guard let frontAppPID = NSWorkspace.shared.frontmostApplication?.processIdentifier else {
        print("Failed to get the frontmost application.")
        return nil
    }
    let appElement = AXUIElementCreateApplication(frontAppPID)
    var focusedWindow: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(
        appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow)
    if result == .success, let window = focusedWindow {
        return (window as! AXUIElement)
    } else {
        print("Failed to get the focused window.")
        return nil
    }
}

// Function to get the monitor where the window is currently located
func getMonitorForWindow(window: AXUIElement) -> NSScreen? {
    var windowFrame = CGRect.zero
    var value: CFTypeRef?

    // Get window position
    if AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &value) == .success,
        AXValueGetValue(value as! AXValue, .cgPoint, &windowFrame.origin)
    {
        // Get window size
        if AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &value) == .success,
            AXValueGetValue(value as! AXValue, .cgSize, &windowFrame.size)
        {
            // Find the screen containing this window
            return NSScreen.screens.first(where: { $0.frame.intersects(windowFrame) })
        }
    }
    return nil
}

// Function to set window position and size
func setWindowPositionAndSize(
    window: AXUIElement, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat
) {
    var position = CGPoint(x: x, y: y)  // Create mutable CGPoint
    var size = CGSize(width: width, height: height)  // Create mutable CGSize
    let positionValue = AXValueCreate(.cgPoint, &position)  // Pass mutable variable
    let sizeValue = AXValueCreate(.cgSize, &size)  // Pass mutable variable
    if let positionValue = positionValue, let sizeValue = sizeValue {
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
    }
}

// Main execution
// Run Aerospace commands
// let flattenStatus = runShellCommand(let flattenStatus = runShellCommand("aerospace layout floating || aerospace layout tiling")
let flattenStatus = runShellCommand("aerospace layout floating || aerospace layout tiling")
if flattenStatus != 0 {
    print("Failed to execute Aerospace commands.")
    exit(1)
}

if let window = getFrontmostWindow() {
    if let screen = getMonitorForWindow(window: window) ?? NSScreen.main {
        let screenFrame = screen.visibleFrame
        let newX = screenFrame.origin.x + (screenFrame.width - desiredWidth) / 2
        let newY = screenFrame.origin.y + (screenFrame.height - desiredHeight) / 2
        
        // Ensure window is centered
        setWindowPositionAndSize(
            window: window, 
            x: newX, 
            y: screenFrame.origin.y + (screenFrame.height - desiredHeight) / 2, 
            width: desiredWidth, 
            height: desiredHeight
        )
    } else {
        print("Failed to get the monitor for the window.")
    }
} else {
    print("No frontmost window found.")
}
