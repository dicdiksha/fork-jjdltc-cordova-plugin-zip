import Foundation
import SSZipArchive


@objc(JJzip) class JJzip : CDVPlugin   {
    
    @objc func zip(_ command: CDVInvokedUrlCommand) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let source = command.arguments[0] as? String
            
            let zipOptions = command.arguments[1]
            let zipFile = (zipOptions as AnyObject).value(forKey: "target") as? String
            
            let directoriesToBeSkipped = command.arguments[2] as? [String] ?? [String]()
            let filesToBeSkipped = command.arguments[3] as? [String] ?? [String]()

            // create the destination directories
            let lastIndexSlash = (zipFile as NSString?)?.range(of: "/", options: .backwards).location ?? 0
            let zipPath = (zipFile as NSString?)?.substring(with: NSRange(location: 0, length: lastIndexSlash + 1))
            
            guard let zipPathString = zipPath else {
                self.errorResponse(command, "compress Operation failed, zip path is nil")
                return
            }
            
            guard let sourcePath = source else {
                self.errorResponse(command, "compress failed source path is nil")
                return
            }
            
            do
            {
                try FileManager.default.createDirectory(atPath: zipPathString.replacingOccurrences(of: "file://", with: ""), withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError
            {
                self.errorResponse(command, "compress Operation failed, Unable to create directory \(error.debugDescription)")
                return
            }

            
            // copy remaining into temp directory with same folder name
            let lastIndexSlashForSourcPath = (sourcePath as NSString?)?.range(of: "/", options: .backwards).location ?? 0
            let sourceFolder = (sourcePath as NSString).substring(from: lastIndexSlashForSourcPath + 1)
            let tempDestinationFolder = FileManager.default.temporaryDirectory.appendingPathComponent(sourceFolder).absoluteString.replacingOccurrences(of: "file://", with: "")
            let deleteSuccess = self.deleteTempContentDirectory(tempDestinationFolder)
            if deleteSuccess == false {
                self.errorResponse(command,  "Unable to delete the temp folder at path \(tempDestinationFolder)")
                return
            }
            
            do
            {
             try FileManager.default.copyItem(atPath: sourcePath.replacingOccurrences(of: "file://", with: ""), toPath: tempDestinationFolder)
            } catch let error as NSError
            {
                self.errorResponse(command, "compress Operation failed, Unable to copy directory \(error.debugDescription) to temp folder")
                return
            }

            // remove skipped files and folders from list
            
            if !filesToBeSkipped.isEmpty {
                for filePath in filesToBeSkipped {
                    do
                    {
                     try FileManager.default.removeItem(atPath: tempDestinationFolder +  "/" + filePath)
                    } catch let error as NSError
                    {
                        print("Unable to delete skipped file in temp folder \(error.debugDescription) ")
                    }

                }
            }
            
            if !directoriesToBeSkipped.isEmpty {
                for directoryPath in directoriesToBeSkipped {
                    do
                    {
                     try FileManager.default.removeItem(atPath: tempDestinationFolder + "/" + directoryPath)
                    } catch let error as NSError
                    {
                        print("Unable to delete skipped file in temp folder \(error.debugDescription) ")
                    }

                }
            }

            // zip the the folder in temp directory
            let success: Bool = SSZipArchive.createZipFile(atPath: zipFile!.replacingOccurrences(of: "file://", with: ""), withContentsOfDirectory: tempDestinationFolder)
            
            _ = self.deleteTempContentDirectory(tempDestinationFolder)
            
            if success == false {
                self.errorResponse(command, "compress is failed")
                return
            }
            
            let responseObj = [
                "success": true,
                "message": "compress Operation success"
            ] as [String : Any]

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: responseObj)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    
    private func deleteTempContentDirectory(_ tempDestinationFolder: String) -> Bool {
        if(FileManager.default.fileExists(atPath: tempDestinationFolder)) {
            do
            {
             try FileManager.default.removeItem(atPath: tempDestinationFolder)
                return true
            } catch let error as NSError
            {
                print("Unable to delete skipped file in \(error.debugDescription) to temp folder")
                return false
            }
        }
        return true;
    }
    
    //UnZip Method.
     @objc func unzip(_ command: CDVInvokedUrlCommand) {
        
            let sourceDirectory =  command.arguments[0] as? String
            guard let sourceDirectoryPath = sourceDirectory else {
                errorResponse(command,  "decompress Operation fail due to source directory path is nil")
                return
            }
            let sourceDictionary = getSourceDictionary(sourceDirectoryPath)
            
            let targetOptions = command.arguments[1]
            let targetPath = (targetOptions as AnyObject).value(forKey: "target") as? String
            
            guard let targetPathString = targetPath else {
                errorResponse(command, "decompress Operation fail due to destination directory path is nil")
                return
            }
            
            let sourcePath = sourceDictionary!["path"] as! String
            let sourceName = sourceDictionary!["name"] as! String

            let success: Bool = SSZipArchive.unzipFile(
                    atPath: sourcePath + sourceName,
                    toDestination: targetPathString.replacingOccurrences(of: "file://", with: "")
            )

            if (success == false) {
                errorResponse(command, "decompress Operation fail")
                return
            }

            let responseObj = [
                "success": true,
                "message": "decompress Operation success"
            ] as [String : Any]

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: responseObj)
                commandDelegate.send(pluginResult, callbackId: command.callbackId)
        
    }
    
    private func errorResponse(_ command: CDVInvokedUrlCommand, _ message: String) {
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
