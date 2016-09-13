// MIT License
//
// Copyright (c) 2016 Anton Schukin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

// MARK: - PhotoDownloader

typealias PhotoDownloaderCompletion = (url: NSURL, data: NSData?, error: NSError?) -> Void

protocol PhotoDownloaderTask {
    func start()
    func cancel()
}

protocol PhotoDownloader {
    func download(photoWithUrl url: NSURL, completion: PhotoDownloaderCompletion) -> PhotoDownloaderTask
}

// MARK: - PhotoStorage

protocol PhotoStorage {
    func photoData(forKey key: String) -> NSData?
    func set(photoData photoData: NSData, forKey key: String)
}

// MARK: - ValueStorage

protocol ValueStorage {
    func set(double double:Double, forKey key: String)
    func get(doubleForKey key: String) -> Double?
}

extension NSUserDefaults: ValueStorage {
    func set(double double: Double, forKey key: String) {
        self.setDouble(double, forKey: key)
    }

    func get(doubleForKey key: String) -> Double? {
        return self.doubleForKey(key)
    }
}

// MARK: - PhotoService

struct Photo {
    let uid: String
    let url: NSURL
}

final class PhotoService {
    let photos: [Photo]
    let downloader: PhotoDownloader
    let photoStorage: PhotoStorage
    let valueStorage: ValueStorage
    let notificationCenter: NSNotificationCenter

    init(photos: [Photo],
         downloader: PhotoDownloader,
         photoStorage: PhotoStorage,
         valueStorage: ValueStorage,
         notificationCenter: NSNotificationCenter) {
        self.photos = photos
        self.downloader = downloader
        self.photoStorage = photoStorage
        self.valueStorage = valueStorage
        self.notificationCenter = notificationCenter
    }
}
