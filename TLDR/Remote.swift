//
//  Remote.swift
//  TLDR
//
//  Created by Suraj Pathak on 20/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation
import SSZipArchive

/// Manages Network connection, including downloading and checking for update
struct NetworkManager {

    static func cachedZipUrl() -> String {
        return Constant.tldrZipUrl
    }

    static func remoteZipUrl() -> String {
        let repo = Repository.master
        return "\(repo.gitUrl)\(repo.user)/\(repo.name)/archive/\(repo.branch).zip"
    }

    static func checkAutoUpdate(printVerbose verbose: Bool) {
        Verbose.out("{{🔍 Checking last update time}}", verbose: verbose)
        guard let localLastUpdateTime = getLastModifiedDate() else {
            updateTldrLibrary()
            return
        }
        // Do a head request to see if remote is updated since this date
        let source = cachedZipUrl()
        guard let url = URL(string: source) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"
        let dateString = localLastUpdateTime.stringInHeaderFormat()
        urlRequest.allHTTPHeaderFields = ["If-Modified-Since" : dateString]
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
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
                let remoteUpdateDate = Date.dateFromHttpDateString(lastModifiedAt) else {
                    updateTldrLibrary()
                    return
                }
                if remoteUpdateDate.compare(localLastUpdateTime) == .orderedAscending {
                    updateTldrLibrary()
                }
            }
        }) 
        task.resume()
    }

    static func updateTldrLibrary() {
        Verbose.out("💿 There is a new update available. Updating a new version now. This might take few seconds.")
        let zipSource = cachedZipUrl()
        DispatchQueue.global().async(execute: {
            guard let url = URL(string: zipSource),
                let data = try? Data(contentsOf: url) else {
                    Verbose.out("Library could not be downloaded at this time. Please try again later.")
                    return
            }
            if (try? data.write(to: URL(fileURLWithPath: FileManager.urlToTldrUpdateFolder()!.path), options: [.atomic])) != nil {
                let destinationUrl = FileManager.urlToTldrUpdateFolder()!.deletingPathExtension
                if SSZipArchive.unzipFile(atPath: FileManager.urlToTldrUpdateFolder()!.path, toDestination: destinationUrl().path) {
                    Verbose.out("🍺 Library is downloaded and updated.")
                    do {
                        try FileManager.fileManager.removeItem(at: FileManager.urlToTldrUpdateFolder()!)
                    } catch {}
                    FileManager.copyFromSourceUrl(destinationUrl(), to: FileManager.urlToTldrFolder(), replaceIfExist: true, onSuccess: {
                        StoreManager.updateDB()
                    })
                    updateLastUpdateDate()
                }
            }
        })
    }

    // swiftlint:enable line_length
    static func updateLastUpdateDate() {
        UserDefaults.standard.set(NSNumber(value: Date().timeIntervalSince1970 as Double), forKey: "LastModifiedDate")
    }

    static func getLastModifiedDate() -> Date? {
        guard let date = UserDefaults.standard.value(forKey: "LastModifiedDate") as? Double else {
            return nil
        }
        return Date(timeIntervalSince1970: date)
    }
}

extension Date {

    static func httpDateFormat() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter
    }

    static func dateFromHttpDateString(_ dateString: String) -> Date? {
        return httpDateFormat().date(from: dateString)
    }

    func stringInHeaderFormat() -> String {
        return Date.httpDateFormat().string(from: self) // eg Wed, 20 Jan 2016 23:15:28 GMT
    }

    func stringInRedableFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: self)
    }
}
