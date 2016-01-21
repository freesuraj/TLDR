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
    
    static func cachedZipUrl() -> String {
        return tldrZipUrl
    }

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
        // Do a head request to see if remote is updated since this date
        let source = cachedZipUrl()
        guard let url = NSURL(string: source) else {
            return
        }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "HEAD"
        request.addValue(localLastUpdateTime.stringInHeaderFormat(), forHTTPHeaderField: "If-Modified-Since")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard let httpResponse = response as? NSHTTPURLResponse else {
                print("The last modified date could not be found. Updating a new version now anyway.")
                updateTldrLibrary()
                return
            }
            if httpResponse.statusCode == 304 {
                print("Current version was updated very recently. Not auto updating now.")
            } else {
                print("The update was too long ago. Updating a new version now.")
                updateTldrLibrary()
            }
        }
        task.resume()
    }

    static func updateTldrLibrary() {
        print("Updating tldr library. This might take few seconds.")
        let zipSource = cachedZipUrl()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            guard let url = NSURL(string: zipSource),
                let data = NSData(contentsOfURL: url) else {
                    print("Zip could not be downloaded")
                    return
            }
            if data.writeToFile(FileManager.urlToTldrUpdateFolder()!.path!, atomically: true) {
                let destinationUrl = FileManager.urlToTldrUpdateFolder()!.URLByDeletingPathExtension!
                if SSZipArchive.unzipFileAtPath(FileManager.urlToTldrUpdateFolder()!.path!, toDestination: destinationUrl.path!) {
                    print("Zip is downloaded, unzipped and saved")
                    do {
                        try FileManager.fileManager.removeItemAtURL(FileManager.urlToTldrUpdateFolder()!)
                    } catch {}
                    FileManager.copyFromSourceUrl(destinationUrl, to: FileManager.urlToTldrFolder(), replaceIfExist: true)
                    updateLastUpdateDate()
                }
            }
        })
    }

    static func updateLastUpdateDate() {
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(double: NSDate().timeIntervalSince1970), forKey: "LastModifiedDate")
    }

    static func getLastModifiedDate() -> NSDate? {
        guard let date = NSUserDefaults.standardUserDefaults().valueForKey("LastModifiedDate") as? Double else {
            return nil
        }
        return NSDate(timeIntervalSince1970: date)
    }
}

extension NSDate {
    func stringInHeaderFormat() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = NSTimeZone(name: "GMT")
        return formatter.stringFromDate(self) // eg Wed, 20 Jan 2016 23:15:28 GMT
    }
}
