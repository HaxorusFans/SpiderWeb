//
//  SpiderWeb.swift
//  SpiderWebExample
//  Created by ZXL on 2025/3/18


import Foundation
import CoreServices

public class SpiderWeb: FolderMonitorDelegate{
    public var id:UUID = UUID()
    var delegate: FolderMonitorDelegate?
    public var location: String
    var fm: FolderMonitor
    
    public init(location: String) {
        self.location = location
        self.fm = FolderMonitor.init(folderPath: location)
        self.fm.delegate = self
    }
    
    public func weaveWeb(){
        self.fm.startMonitoring()
    }
    
    public func cleanWeb(){
        self.fm.stopMonitoring()
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
