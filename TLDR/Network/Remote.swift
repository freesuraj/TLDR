//
//  Remote.swift
//  TLDR
//
//  Created by Suraj Pathak on 20/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation
import ZipArchive
import Combine

/// Manages Network connection, including downloading and checking for update
struct NetworkManager {

    static func tldrZipUrl() -> String {
        return Constant.tldrZipUrl
    }
    
    static func indexUrl() -> String {
        return Constant.tldrIndexUrl
    }

    static func checkAutoUpdate(printVerbose verbose: Bool) {
        Verbose.out("{{🔍 Checking last update time}}", verbose: verbose)
        guard let localLastUpdateTime = getLastModifiedDate() else {
            updateTldrLibrary()
            return
        }
        // Do a head request to see if remote is updated since this date
        let source = tldrZipUrl()
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
                Verbose.out("The current version which was updated at _\(localLastUpdateTime.stringInRedableFormat)_ is the latest version. Not auto updating now.", verbose: verbose)
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
        Task {
            try? await updateTldrLibraryAsync()
        }
    }
    
    static func updateTldrLibraryAsync() async throws {
        Verbose.out("💿 There is a new update available. Updating a new version now. This might take few seconds.")
        
        guard let zipUrl = URL(string: tldrZipUrl()), let indexUrl = URL(string: indexUrl()) else { return }
        let (tempIndexUrl, _) = try await URLSession.shared.download(for: URLRequest(url: indexUrl))
        let (tempZipUrl, _) = try await URLSession.shared.download(for: URLRequest(url: zipUrl))
                
        
        let updateFolderUrl = FileManager.updateFolderUrl()!
        if SSZipArchive.unzipFile(atPath: tempZipUrl.path, toDestination: updateFolderUrl.path()) {
            Verbose.out("🍺 Library is downloaded and updated.")
            FileManager.copyFromSourceUrl(updateFolderUrl, to: FileManager.tldrFolderUrl(), replaceIfExist: true, onSuccess: {
                // Copy index as well
                FileManager.copyFromSourceUrl(tempIndexUrl, to: FileManager.indexFileUrl(), replaceIfExist: true, onSuccess: {
                    StoreManager.updateDB()
                })
                
                // Delete temp file
                do {
                    try FileManager.fileManager.removeItem(at: FileManager.updateFolderUrl()!)
                } catch {}
            })
            updateLastUpdateDate()
        }
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

    static var httpDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter
    }()

    static func dateFromHttpDateString(_ dateString: String) -> Date? {
        return httpDateFormat.date(from: dateString)
    }

    func stringInHeaderFormat() -> String {
        return Date.httpDateFormat.string(from: self) // eg Wed, 20 Jan 2016 23:15:28 GMT
    }

    var stringInRedableFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: self)
    }
}
