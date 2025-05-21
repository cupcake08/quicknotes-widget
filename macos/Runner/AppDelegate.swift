import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    var statusBarController: StatusBarController?
    var flutterUIPopover = NSPopover.init()
    
    override init() {
        flutterUIPopover.behavior = NSPopover.Behavior.transient
    }
    
    override func applicationDidFinishLaunching(_ aNotification: Notification) {
      // Get the FlutterViewController from the main Flutter window
      let flutterViewController: FlutterViewController =
        mainFlutterWindow?.contentViewController as! FlutterViewController
        
      // Set the size of the popover
      flutterUIPopover.contentSize = NSSize(width: 360, height: 300)
      
      // Set the content view controller for the popover to the FlutterViewController
      flutterUIPopover.contentViewController = flutterViewController
      
      // Initialize the status bar controller with the popover
      statusBarController = StatusBarController.init(flutterUIPopover)
      
      // Close the default Flutter window as the Flutter UI will be displayed in the popover
      mainFlutterWindow?.close()
      
      // Call the superclass's applicationDidFinishLaunching function to perform any additional setup
      super.applicationDidFinishLaunching(aNotification)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
