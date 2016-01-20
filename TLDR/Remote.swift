//
//  Remote.swift
//  TLDR
//
//  Created by Suraj Pathak on 20/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation
import SSZipArchive

struct NetworkManager {

    static func remoteZipUrl() -> String {
        guard let gitUrl = remoteConfig["gitUrl"],
            let user = remoteConfig["user"],
            let repo = remoteConfig["repo"],
            let branch = remoteConfig["branch"] else {
                return tldrZipUrl
        }
        return "\(gitUrl)\(user)/\(repo)/archive/\(branch).zip"
    }

    static func checkAutoUpdate() {
        print("checking last update time..")
        guard let localLastUpdateTime = getLastModifiedDate() else {
            print("library was never updated. Will update now")
            updateTldrLibrary()
            return
        }
        let timeIntervalSinceLastUpdate = NSDate().timeIntervalSince1970 - localLastUpdateTime
        let forceUpdateInterval = Double(5 * 24 * 60 * 60) // i.e. 5 days
        if  timeIntervalSinceLastUpdate > forceUpdateInterval {
            print("The update was too long ago. Updating a new version now.")
            updateTldrLibrary()
        } else {
            print("Current version was updated very recently. Not auto updating now.")
        }
    }

    static func updateTldrLibrary() {
        print("Updating tldr library. This might take few seconds.")
        let zipSource = remoteZipUrl()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            guard let url = NSURL(string: zipSource),
                let data = NSData(contentsOfURL: url) else {
                    print("Zip could not be downloaded")
                    return
            }
            if data.writeToFile(FileManager.urlToTldrUpdateFolder()!.path!, atomically: true) {
                let destinationUrl = FileManager.urlToTldrUpdateFolder()!.URLByDeletingPathExtension!
                if SSZipArchive.unzipFileAtPath(FileManager.urlToTldrUpdateFolder()!.path!, toDestination: destinationUrl.path!) {
                    updateLastUpdateDate()
                    print("Zip is downloaded, unzipped and saved")
                    do {
                        try FileManager.fileManager.removeItemAtURL(FileManager.urlToTldrUpdateFolder()!)
                    } catch {}
                    FileManager.copyFromSourceUrl(destinationUrl, to: FileManager.urlToTldrFolder(), replaceIfExist: true)
                }
            }
        })
    }

    static func updateLastUpdateDate() {
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(double: NSDate().timeIntervalSince1970), forKey: "LastModifiedDate")
    }

    static func getLastModifiedDate() -> NSTimeInterval? {
        guard let date = NSUserDefaults.standardUserDefaults().valueForKey("LastModifiedDate") as? Double else {
            return nil
        }
        return date
    }
}
