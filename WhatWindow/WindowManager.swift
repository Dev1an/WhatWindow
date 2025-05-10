import Cocoa            // pulls in AppKit + Core Graphics
import CoreGraphics     // explicit import is optional but makes the intent clear

enum WindowManager {
    static private let queryOptions: CGWindowListOption = [
        .optionOnScreenOnly,        // only those that are visible *now*
        .excludeDesktopElements     // ignore the wallpaper and the menu bar shadow layer
    ]
    
    static var processes: [Process: [Window]] {
        guard let windows = CGWindowListCopyWindowInfo(Self.queryOptions, kCGNullWindowID)
                as? [[String: AnyObject]] else {
            fatalError("Could not obtain window list")
        }
        let processes = Dictionary(grouping: windows) { info in
            Process(
                id: info[kCGWindowOwnerPID as String] as! pid_t,
                name: info[kCGWindowOwnerName as String] as? String
            )
        }
        return processes.mapValues { windows in
            windows.map { info in
                Window(
                    id: info[kCGWindowNumber as String] as! CGWindowID,
                    bounds: CGRect(dictionaryRepresentation: info[kCGWindowBounds as String] as! CFDictionary)!,
                    layerNumber: info[kCGWindowLayer as String] as! CFNumber,
                    name: info[kCGWindowName as String] as? String
                )
            }
        }
    }
    
    struct Process: Identifiable, Hashable {
        let id: pid_t
        let name: String?
    }
    
    struct Window: Identifiable, Hashable {
        let id: CGWindowID
        let bounds: CGRect
        let layerNumber: CFNumber
        let name: String?
    }
}
