import Foundation


public func saveToFile(str: String, file: String) {

    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

        let fileURL = dir.appendingPathComponent(file)

        //writing
        do {
            
            try str.write(to: fileURL, atomically: false, encoding: .utf8)
            
            print("All done!")
            
            let source =
        """
        
            tell application "Finder" to open POSIX file "\(fileURL)"
        
        """
            
            let script = NSAppleScript(source: source)!
            
            _ = script.executeAndReturnError(nil)
            
        } catch { print("Could not save the image.") }
    }
    
}
