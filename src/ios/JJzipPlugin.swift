import Foundation
import SSZipArchive
@objc(JJzip) class JJzip : CDVPlugin   {
    
    //ZiP Method.
    @objc func zip(_ command: CDVInvokedUrlCommand?) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let directoriesToBeSkipped = command?.arguments[0] as? String
        let filesToBeSkipped = command?.arguments[1] as? [String]
               pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs:"Hi Compress..!!!")
        self.commandDelegate.send(pluginResult, callbackId: command?.callbackId)
        
    }
    
    //UnZip Method.
     @objc func unzip(_ command: CDVInvokedUrlCommand) {
        
            let sourceDirectory =  command.arguments[0] as? String
            guard let sourceDirectoryPath = sourceDirectory else {
                let responseObj = [
                    "success": false,
                    "message": "decompress Operation fail due to source directory path is nil",
                ] as [String : Any]

                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: responseObj)
                commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
            let sourceDictionary = getSourceDictionary(sourceDirectoryPath)
            
            let targetOptions = command.arguments[1]
            let targetPath = (targetOptions as AnyObject).value(forKey: "target") as? String
            
            guard let targetPathString = targetPath else {
                let responseObj = [
                    "success": false,
                    "message": "decompress Operation fail due to destination directory path is nil",
                ] as [String : Any]

                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: responseObj)
                commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
            
            let sourcePath = sourceDictionary!["path"] as! String
            let sourceName = sourceDictionary!["name"] as! String

            let success: Bool = SSZipArchive.unzipFile(
                    atPath: sourcePath + sourceName,
                    toDestination: targetPathString.replacingOccurrences(of: "file://", with: "")
            )

            if (success == false) {
                let responseObj = [
                    "success": false,
                    "message": "decompress Operation fail",
                ] as [String : Any]

                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: responseObj)
                commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }

            let responseObj = [
                "success": true,
                "message": "decompress Operation success"
            ] as [String : Any]

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: responseObj)
                commandDelegate.send(pluginResult, callbackId: command.callbackId)
        
    }


    // getSourceDictionary Method.
    @objc func getSourceDictionary(_ sourceString: String?) -> [AnyHashable : Any]? {
        let lastIndexSlash = (sourceString as NSString?)?.range(of: "/", options: .backwards).location ?? 0
        let path = (sourceString as NSString?)?.substring(with: NSRange(location: 0, length: lastIndexSlash + 1))
        let name = (sourceString as NSString?)?.substring(from: lastIndexSlash + 1)
        let sourceDictionary = [
            "path": path?.replacingOccurrences(of: "file://", with: "") ?? "",
            "name": name ?? ""
        ]
        return sourceDictionary
    }

}
