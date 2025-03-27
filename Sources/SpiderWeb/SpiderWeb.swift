//
//  SpiderWeb.swift
//  SpiderWebExample
//  Created by ZXL on 2025/3/18


import Foundation
import CoreServices
import AppKit

public class SpiderWebBookmarkManager {
    @MainActor private static let defaults = UserDefaults(suiteName: "com.HaxorusFans.SpiderWeb.Bookmarks")!
      
    @MainActor static func saveBookmarks(url: URL) -> Bool {
        var arr:[Data] = []
        if let bookmark = try? url.bookmarkData(options: .withSecurityScope){
            guard let dataArray = defaults.array(forKey: "authorizedDirectoryBookmarks") as? [Data] else {
                arr.append(bookmark)
                defaults.set(arr, forKey: "authorizedDirectoryBookmarks")
                return true
            }
            arr = dataArray
            arr.append(bookmark)
            defaults.set(arr, forKey: "authorizedDirectoryBookmarks")
            return true
        }
        return false
    }
      
    @MainActor static func loadBookmarks() -> [URL]? {
        guard let dataArray = defaults.array(forKey: "authorizedDirectoryBookmarks") as? [Data] else { return nil }
        return dataArray.compactMap { data in
            var isStale = false
            return try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
        }
    }
}


// 引导用户授权目录（沙盒模式专用）
@MainActor public func requestDirectoryAccess(completion: @escaping (URL?) -> Void) {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    panel.begin { response in
        guard response == .OK, let _ = panel.url else {
            completion(nil)
            return
        }
        // 保存书签并返回授权结果
        let success = SpiderWebBookmarkManager.saveBookmarks(url: panel.url!)
        completion(success ? panel.url : nil)
    }
}

public class SpiderWeb: FolderMonitorDelegate{
    public var id:UUID = UUID()
    var delegate: FolderMonitorDelegate?
    public var location: URL?
    var fm: FolderMonitor?
    
    public init() {
    }
    
    @MainActor public func weaveWeb(){
        requestDirectoryAccess { URL in
            if let url = URL {
                url.startAccessingSecurityScopedResource()
                self.location = url
                self.fm = FolderMonitor.init(folderPath: url.path)
                self.fm!.delegate = self
                self.fm!.startMonitoring()
            }
        }
        
    }
    
    public func cleanWeb(){
        self.fm?.stopMonitoring()
        self.location?.stopAccessingSecurityScopedResource()
    }
    
    deinit {
        cleanWeb()
    }
    
    /// Delegate
    func itemCreated(pathType: PathType, path:String){
        self.delegate?.itemCreated(pathType: pathType, path: path)
    }
    
    func itemRemoved(pathType: PathType, path: String){
        self.delegate?.itemRemoved(pathType: pathType, path: path)
    }
    
    func itemModified(pathType: PathType, path: String){
        self.delegate?.itemModified(pathType: pathType, path: path)
    }
    
    func itemRenamed(pathType: PathType, path: String){
        self.delegate?.itemRenamed(pathType: pathType, path: path)
    }
}

public class TestClass: FolderMonitorDelegate{
    public var sw: SpiderWeb?
    public init(sw: SpiderWeb? = nil) {
        self.sw = sw
        self.sw?.delegate = self
    }
    
    func itemCreated(pathType: PathType, path:String){
        print("created!!!!!!!!")
    }
    
    func itemRenamed(pathType: PathType, path: String){
        print("rename!!!!!!!!")
    }
    
    func itemRemoved(pathType: PathType, path: String) {
        print("remove!!!!!!!!")
    }
    
    func itemModified(pathType: PathType, path: String) {
        print("modified!!!!!!!!")
    }
}
