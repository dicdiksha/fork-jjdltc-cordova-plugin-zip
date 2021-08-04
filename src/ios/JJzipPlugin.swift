//
//  JJzipPlugin.swift
//
//
//  Created by Pace Wisdom on 01/07/21.
//
import Foundation
import SSZipArchive


@objc(JJzip) class JJzip : CDVPlugin   {
    
    //ZiP Method.
    @objc func zip(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let source = command.arguments[0] as? String
        let directoriesToBeSkipped = command.arguments[0] as? String
        let filesToBeSkipped = command.arguments[1] as? [String]
        pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs:"Hi Compress..!!!")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        
    }
    
    //UnZip Method.
     @objc func unzip(_ command: CDVInvokedUrlCommand) {
        
            let sourceDirectory =  command.arguments[0] as? String
            guard let sourceDirectoryPath = sourceDirectory else {
                unZipErrorResponse(command,  "decompress Operation fail due to source directory path is nil")
                return
            }
            let sourceDictionary = getSourceDictionary(sourceDirectoryPath)
            
            let targetOptions = command.arguments[1]
            let targetPath = (targetOptions as AnyObject).value(forKey: "target") as? String
            
            guard let targetPathString = targetPath else {
                unZipErrorResponse(command, "decompress Operation fail due to destination directory path is nil")
                return
            }
            
            let sourcePath = sourceDictionary!["path"] as! String
            let sourceName = sourceDictionary!["name"] as! String

            let success: Bool = SSZipArchive.unzipFile(
                    atPath: sourcePath + sourceName,
                    toDestination: targetPathString.replacingOccurrences(of: "file://", with: "")
            )

            if (success == false) {
                unZipErrorResponse(command, "decompress Operation fail")
                return
            }

            let responseObj = [
                "success": true,
                "message": "decompress Operation success"
            ] as [String : Any]

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: responseObj)
                commandDelegate.send(pluginResult, callbackId: command.callbackId)
        
    }
    
    private func unZipErrorResponse(_ command: CDVInvokedUrlCommand, _ message: String) {
        let responseObj = [
            "success": false,
            "message": message,
        ] as [String : Any]

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: responseObj)
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
