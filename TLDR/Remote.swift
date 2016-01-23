//
//  Remote.swift
//  TLDR
//
//  Created by Suraj Pathak on 20/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation
import SSZipArchive

struct FileManager {
    static let fileManager = NSFileManager.defaultManager()
    static func copyFromSourceUrl(fromUrl: NSURL?, to toUrl: NSURL?, replaceIfExist: Bool) {
        guard let destinationUrl = toUrl,
            let destinationPath = destinationUrl.path,
            let sourceUrl = fromUrl else { return }
        if fileManager.fileExistsAtPath(destinationPath) {
            if !replaceIfExist {
                print("Directory exists. Not copying.")
                return
            } else {
                do {
                    try fileManager.removeItemAtURL(destinationUrl)
                } catch {}
            }
        }
        do {
            try fileManager.copyItemAtURL(sourceUrl, toURL: destinationUrl)
            dispatch_async(dispatch_get_main_queue(), {
                StoreManager.updateDB()
            })
        } catch let error as NSError {
            print("Error: copying file from \(sourceUrl) to \(destinationUrl) encountered error.\n \(error)")
        }
    }

    static func copyBundleToDocument(replaceIfExist: Bool) {
        let destinationUrl = FileManager.urlToTldrFolder()
        let sourceUrl = FileManager.urlToBundleFolder()
        copyFromSourceUrl(sourceUrl, to: destinationUrl, replaceIfExist: replaceIfExist)
    }

    static func urlToTldrFolder() -> NSURL? {
        guard let documentUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            // Create Directory and Copy
            return nil
        }
        let tldrUrl = documentUrl.URLByAppendingPathComponent("tldr")
        return tldrUrl
    }

    static func urlToIndexJson() -> NSURL? {
        guard let tldrFolder = urlToTldrFolder() else {
            return nil
        }
        return tldrFolder.URLByAppendingPathComponent("/pages/index.json")
    }

    static func urlToTldrUpdateFolder() -> NSURL? {
        guard let documentUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            // Create Directory and Copy
            return nil
        }
        let tldrUrl = documentUrl.URLByAppendingPathComponent("tldr-update.zip")
        return tldrUrl
    }

    static func urlToBundleFolder() -> NSURL? {
        let path = NSBundle.mainBundle().URLForResource("tldr", withExtension: "bundle")
        return path
    }

    static func contentOfFileAtTldrPages(type: String, name: String) -> String? {
        guard let tldrFolderUrl = FileManager.urlToTldrFolder() else {
            return nil
        }
        let filePath = tldrFolderUrl.URLByAppendingPathComponent("/pages/\(type)/\(name).md")
        do {
            let value = try String(contentsOfURL: filePath, encoding: NSUTF8StringEncoding)
            return value
        } catch {
            return nil
        }
    }
}

/// Manages Network connection, including downloading and checking for update
struct NetworkManager {

    static func cachedZipUrl() -> String {
        return Constant.tldrZipUrl
    }

    static func remoteZipUrl() -> String {
        guard let gitUrl = Constant.remoteConfig["gitUrl"],
            let user = Constant.remoteConfig["user"],
            let repo = Constant.remoteConfig["repo"],
            let branch = Constant.remoteConfig["branch"] else {
                return Constant.tldrZipUrl
        }
        return "\(gitUrl)\(user)/\(repo)/archive/\(branch).zip"
    }

    static func checkAutoUpdate(printVerbose verbose: Bool) {
        Verbose.out("{{🔍 Checking last update time}}", verbose: verbose)
        guard let localLastUpdateTime = getLastModifiedDate() else {
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
        let dateString = localLastUpdateTime.stringInHeaderFormat()
        request.addValue(dateString, forHTTPHeaderField: "If-Modified-Since")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard let httpResponse = response as? NSHTTPURLResponse else {
                Verbose.out("The last modified date could not be found. Updating a new version now anyway.")
                updateTldrLibrary()
                return
            }
            if httpResponse.statusCode == 304 {
                // swiftlint:disable line_length
                Verbose.out("The current version which was updated at _\(localLastUpdateTime.stringInRedableFormat())_ is the latest version. Not auto updating now.", verbose: verbose)
            } else {
                // Sometimes there's a bug with the returned header.Even though status is 200, the content has not been actually modified. We'll check for that here
                guard let lastModifiedAt = httpResponse.allHeaderFields["Last-Modified-Date"] as? String,
                let remoteUpdateDate = NSDate.dateFromHttpDateString(lastModifiedAt) else {
                    updateTldrLibrary()
                    return
                }
                if remoteUpdateDate.compare(localLastUpdateTime) == .OrderedAscending {
                    updateTldrLibrary()
                }
            }
        }
        task.resume()
    }

    static func updateTldrLibrary() {
        Verbose.out("💿 There is a new update available. Updating a new version now. This might take few seconds.")
        let zipSource = cachedZipUrl()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            guard let url = NSURL(string: zipSource),
                let data = NSData(contentsOfURL: url) else {
                    Verbose.out("Library could not be downloaded at this time. Please try again later.")
                    return
            }
            if data.writeToFile(FileManager.urlToTldrUpdateFolder()!.path!, atomically: true) {
                let destinationUrl = FileManager.urlToTldrUpdateFolder()!.URLByDeletingPathExtension!
                if SSZipArchive.unzipFileAtPath(FileManager.urlToTldrUpdateFolder()!.path!, toDestination: destinationUrl.path!) {
                    Verbose.out("🍺 Library is downloaded and updated.")
                    do {
                        try FileManager.fileManager.removeItemAtURL(FileManager.urlToTldrUpdateFolder()!)
                    } catch {}
                    FileManager.copyFromSourceUrl(destinationUrl, to: FileManager.urlToTldrFolder(), replaceIfExist: true)
                    updateLastUpdateDate()
                }
            }
        })
    }

    // swiftlint:enable line_length
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

    static func httpDateFormat() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = NSTimeZone(name: "GMT")
        return formatter
    }

    static func dateFromHttpDateString(dateString: String) -> NSDate? {
        return httpDateFormat().dateFromString(dateString)
    }

    func stringInHeaderFormat() -> String {
        return NSDate.httpDateFormat().stringFromDate(self) // eg Wed, 20 Jan 2016 23:15:28 GMT
    }

    func stringInRedableFormat() -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        return formatter.stringFromDate(self)
    }
}
