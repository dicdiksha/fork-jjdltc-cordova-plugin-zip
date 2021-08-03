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
    @objc func zip(_ command: CDVInvokedUrlCommand?) {
        var pluginResult: CDVPluginResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR)
        let directoriesToBeSkipped = command?.arguments[0] as? String
        let filesToBeSkipped = command?.arguments[1] as? [String]
               pluginResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs:"Hi Compress..!!!")
        self.commandDelegate.send(pluginResult, callbackId: command?.callbackId)
        
    }
    
//UnZip Method.
 @objc func unzip(_ command: CDVInvokedUrlCommand?) {
    
    do {
        let sourceDictionary = getSourceDictionary(command?.arguments[0] as? String)
        let targetOptions = command?.arguments[1]
        var targetPath = (targetOptions! as AnyObject).value(forKey: "target") as! String
        targetPath = targetPath.replacingOccurrences(of: "file://", with: "")
        let sourcePath = sourceDictionary!["path"] as! String
        let sourceName = sourceDictionary!["name"] as! String

            let success = SSZipArchive.unzipFile(
                atPath: (sourcePath ?? "") + (sourceName ?? ""),
                toDestination: targetPath
            )


            let responseObj = [
                "success": true,
                "message": "decompress Operation success"
            ] as [String : Any]

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: responseObj)
            commandDelegate.send(pluginResult, callbackId: command?.callbackId)
    } catch let error {
        let responseObj = [
            "success": false,
            "message": "decompress Operation fail with \(error.localizedDescription)",
        ] as [String : Any]

    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: responseObj)
        commandDelegate.send(pluginResult, callbackId: command?.callbackId)
    }
    
    
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



@objc func jsEvent(_ event: String?, _ data: String?) {
    var eventStrig = "cordova.fireDocumentEvent('\(event ?? "")'"
    // NSString *eventStrig = [NSString stringWithFormat:@"console.log('%@'", event];

    if let data = data {
        eventStrig = "\(eventStrig),\(data)"
    }

    eventStrig = eventStrig + ");"

    commandDelegate.evalJs(eventStrig)
}


@objc func dictionary(toJSONString toCast: [AnyHashable : Any]?) -> String? {
    var error: Error?
    var jsonData: Data? = nil
    do {
        if let toCast = toCast {
            jsonData = try JSONSerialization.data(withJSONObject: toCast, options: .prettyPrinted)
        }
    } catch {
    }
    if jsonData == nil {
        return nil
    } else {
        if let jsonData = jsonData {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}

    
}
