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

@testable import NSSpain
import XCTest

/* 
 Requirements:
  - Download user photos
  - Store compressed and original photos
  - Do it no more than every four hours
  - Do it when your app becomes active
*/

class PhotoServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testThat_WhenAppBecomesActive_ThenServiceDownloadPhotos() {
        XCTAssertFalse(true)
    }

    func testThat_WhenPhotoIsDownloaded_ThenServiceStoresIt() {
        XCTAssertFalse(true)
    }

    func testThat_WhenPhotoIsDownloaded_ThenServiceStoresCompressedPhoto() {
        XCTAssertFalse(true)
    }

    func testThat_GivenServiceDownloadedPhotosLessThan4HoursAgo_WhenAppBecomesActive_ThenServiceDoesntDownloadPhotos() {
        XCTAssertFalse(true)
    }

    func testThat_GivenServiceDownloadedPhotosMoreThan4HoursAgo_WhenAppBecomesActive_ThenServiceDownloadsPhotos() {
        XCTAssertFalse(true)
    }
}

// MARK: - PhotoDownloader

class DummyPhotoDownloaderTask: PhotoDownloaderTask {
    func start() {}
    func cancel() {}
}

class CountingPhotoDownloader: PhotoDownloader {
    var numberOfDownloadedPhotos = 0
    func download(photoWithUrl url: NSURL, completion: PhotoDownloaderCompletion) -> PhotoDownloaderTask {
        numberOfDownloadedPhotos += 1
        completion(url: url, data: NSData(), error: nil)
        return DummyPhotoDownloaderTask()
    }
}

class FailingPhotoDownloader: PhotoDownloader {
    func download(photoWithUrl url: NSURL, completion: PhotoDownloaderCompletion) -> PhotoDownloaderTask {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        completion(url: url, data: nil, error: error)
        return DummyPhotoDownloaderTask()
    }
}

// MARK: - PhotoStorage

class PhotoStorageSpy: PhotoStorage {
    var onPhotoDataForKey: (key: String) -> NSData? = { (key) in
        return nil
    }

    func photoData(forKey key: String) -> NSData? {
        return self.onPhotoDataForKey(key: key)
    }

    var onSetPhotoDataForKey: (photoData: NSData, key: String) -> Void = { (photoData, key) in
    }

    func set(photoData photoData: NSData, forKey key: String) {
        self.onSetPhotoDataForKey(photoData: photoData, key: key)
    }
}

// MARK: - ValueStorage

class FakeValueStorage: ValueStorage {
    var storage = [String: Double]()

    func set(double double:Double, forKey key: String) {
        self.storage[key] = double
    }

    func get(doubleForKey key: String) -> Double? {
        return self.storage[key]
    }
}
