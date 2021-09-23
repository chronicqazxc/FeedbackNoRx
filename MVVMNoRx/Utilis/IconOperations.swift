//
//  AvatarOperations.swift
//  MVVMNoRx
//
//  Created by YuHan Hsiao on 2021/09/12.
//

import UIKit

enum IconDownloadStatus {
    case new, downloaded, failed
}

enum OperationStatus {
    case cancel, finished
}

final class AppIconDownloader: Operation {
    var url: String!
    var iconDownloadStatus = IconDownloadStatus.new
    var image: UIImage?
    
    convenience init(url: String) {
        self.init()
        self.url = url
    }
    
    override func main() {
        if isCancelled {
            assert(image != nil, "image should not be nil.")
            return
        }
        
        guard let url = URL(string: url),
              let imageData = try? Data(contentsOf: url) else {
            assert(image != nil, "image should not be nil.")
            return
        }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            image = UIImage(data: imageData)
            assert(image != nil, "image should not be nil.")
            iconDownloadStatus = .downloaded
        } else {
            image = UIImage(named: "Failed")
            iconDownloadStatus = .failed
        }
    }
}

class PendingIconDownloaderOperations {
    /// Data Source
    fileprivate var appIconDownloaders = [AppIconDownloader]()
    typealias Key = AnyHashable
    /// Control respective AppIconDownloaders
    fileprivate var downloadsInProgress = [Key: AppIconDownloader]()
    fileprivate lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var count: Int {
        return appIconDownloaders.count
    }
    
    subscript (index: Int) -> AppIconDownloader {
        get {
            let downloader = appIconDownloaders[index]
            if downloader.isCancelled == true {
                let newDownloader = AppIconDownloader(url: downloader.url)
                appIconDownloaders[index] = newDownloader
                return newDownloader
            }
            return appIconDownloaders[index]
        }
        set {
            appIconDownloaders[index] = newValue
        }
    }
    
    func startDownload(for appIconDownloader: AppIconDownloader,
                       at key: Key,
                       completeHandler: @escaping (OperationStatus)->Void) {
        guard appIconDownloader.iconDownloadStatus == .new else {
            return
        }
        
        guard downloadsInProgress[key] == nil else {
            return
        }
        appIconDownloader.completionBlock = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            if appIconDownloader.isCancelled {
                completeHandler(.cancel)
            }
            DispatchQueue.main.async {
                if appIconDownloader.isFinished && !appIconDownloader.isCancelled {
                    assert(appIconDownloader.image != nil, "image should not be nil")
                }
                strongSelf.downloadsInProgress.removeValue(forKey: key)
                completeHandler(.finished)
            }
        }
        if !downloadQueue.operations.contains(appIconDownloader) {
            downloadQueue.addOperation(appIconDownloader)
        }
        downloadsInProgress[key] = appIconDownloader
    }
    
    func cancel(at keys: [Key]) {
        for key in keys {
            if let pendingDownload = downloadsInProgress[key] {
                if pendingDownload.isExecuting || pendingDownload.isReady {
                    pendingDownload.cancel()
                }
                downloadsInProgress.removeValue(forKey: key)
            }
        }
    }
    
    func suspendAllOperations() {
        downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        downloadQueue.isSuspended = false
    }

    func loadImagesForOnScreenCells(indexPathsForVisibleRows pathes: [IndexPath],
                                    completeHander: @escaping ([IndexPath])->Void) {

        guard let allPendingOperations = Set(downloadsInProgress.keys) as? Set<IndexPath> else {
            return
        }

        var toBeCancelled = allPendingOperations
        let visiblePaths = Set(pathes)
        toBeCancelled.subtract(visiblePaths)

        for indexPath in visiblePaths {
            let appIconDownloader = self[indexPath.row]
            startDownload(for: appIconDownloader, at: indexPath) {
                if $0 == .finished {
                    DispatchQueue.main.async {
                        completeHander([indexPath])
                    }
                }
            }
        }
        cancel(at: Array(toBeCancelled))
    }
}

extension PendingIconDownloaderOperations {
    convenience init(downloaders: [AppIconDownloader]) {
        self.init()
        self.appIconDownloaders = downloaders
    }
    
    func append(_ downloaders: [AppIconDownloader]) {
        self.appIconDownloaders.append(contentsOf: downloaders)
    }
}
