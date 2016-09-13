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
import UIKit

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

// MARK: - CurrentTimeProvider

typealias CurrentTimeProvider = () -> NSTimeInterval

// MARK: - PhotoCompressor

protocol PhotoCompressor {
    func compress(photo photo: UIImage) -> NSData?
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
    let photoCompressor: PhotoCompressor
    let valueStorage: ValueStorage
    let currentTimeProvider: CurrentTimeProvider
    let notificationCenter: NSNotificationCenter

    init(photos: [Photo],
         downloader: PhotoDownloader,
         photoStorage: PhotoStorage,
         photoCompressor: PhotoCompressor,
         valueStorage: ValueStorage,
         currentTimeProvider: CurrentTimeProvider,
         notificationCenter: NSNotificationCenter) {
        self.photos = photos
        self.downloader = downloader
        self.photoStorage = photoStorage
        self.photoCompressor = photoCompressor
        self.valueStorage = valueStorage
        self.currentTimeProvider = currentTimeProvider
        self.notificationCenter = notificationCenter

        self.notificationCenter.addObserver(self,
                                            selector: #selector(PhotoService.beginSync),
                                            name: UIApplicationDidBecomeActiveNotification,
                                            object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    var downloadQueue = [Photo]()
    var downloadTask: PhotoDownloaderTask?

    @objc private func beginSync() {
        let key = "previousSyncTime"
        let fourHours: NSTimeInterval = 4 * 60 * 60
        let currentTime = self.currentTimeProvider()
        if let previousTime = self.valueStorage.get(doubleForKey: key) {
            if previousTime > 0 && (currentTime - previousTime) < fourHours {
                return
            }
        }
        self.valueStorage.set(double: currentTime, forKey: key)

        if let downloadTask = downloadTask {
            downloadTask.cancel()
            downloadQueue.removeAll()
        }

        downloadQueue.appendContentsOf(photos)
        downloadNextPhoto()
    }

    private func downloadNextPhoto() {
        guard let photo = downloadQueue.first else { return }
        downloadQueue.removeFirst()

        downloadTask = downloader.download(photoWithUrl: photo.url, completion: { [weak self] (url, data, error) in
            guard let sSelf = self else { return }
            sSelf.downloadNextPhoto()
        })
        downloadTask?.start()
    }
}
