//
//  FolderMonitor.swift
//  SpiderWebExample
//  Created by ZXL on 2025/3/19
        

import Foundation


protocol FolderMonitorDelegate {
    func itemCreated(pathType: PathType, path:String)
    func itemRemoved(pathType: PathType,path:String)
    func itemModified(pathType: PathType, path:String)
    func itemRenamed(pathType: PathType, path:String)
}

extension FolderMonitorDelegate{
    func itemCreated(pathType: PathType, path:String){}
    func itemRemoved(pathType: PathType, path:String){}
    func itemModified(pathType: PathType, path:String){}
    func itemRenamed(pathType: PathType, path:String){}
}

enum PathType {
    case File
    case Directory
    case SystemLink
    case Unknown
    
    var type: String {
        switch self {
            case .File:
                return "File"
            case .Directory:
                return "Directory"
            case .SystemLink:
                return "SystemLink"
            case .Unknown:
                return "Unknown"
        }
    }
}

class FolderMonitor {
    private var stream: FSEventStreamRef?
    private let folderPath: String
    var delegate : FolderMonitorDelegate?

    init(folderPath: String) {
        self.folderPath = folderPath
    }

    func startMonitoring() {
        let fm:FileManager = FileManager.default
        guard fm.fileExists(atPath: folderPath)else{
            print("Start monitoring failed, \(folderPath) is not exists!")
            return
        }
        print("Start monitoring: \(folderPath)...\n")

        let pathsToWatch = [folderPath] as CFArray
        
        let unmanagedSelf = Unmanaged.passRetained(self)
        var context = FSEventStreamContext(version: 0, info: unmanagedSelf.toOpaque(), retain: nil, release: nil, copyDescription: nil)

        stream = FSEventStreamCreate(
            kCFAllocatorDefault,
            eventCallback,
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            1.0,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes)
        )

        guard let stream = stream else {
            print("Unable to create FSEvents listener stream")
            return
        }
        FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(stream)
    }

    func stopMonitoring() {
        let fm:FileManager = FileManager.default
        guard fm.fileExists(atPath: folderPath)else{
            print("Stop monitoring failed, \(folderPath) is not exists!")
            return
        }
        if let stream = stream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            self.stream = nil
            print("Stop monitoring: \(folderPath).")
        }
        Unmanaged.passUnretained(self).release()
    }

    func safeDescribeEvent(eventFlags: FSEventStreamEventFlags, path:String) throws -> String {
        var pathType: PathType = .Unknown
        // path type
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsFile) != 0 {
            pathType = .File
        }
        else if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsDir) != 0 {
            pathType = .Directory
        }
        else if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsSymlink) != 0 {
            pathType = .SystemLink
        }
        else{
            return "Unknown event！ (eventFlags: \(eventFlags))"
        }
        
        var changeTypes: [String] = []
        //change type
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated) != 0 {
            changeTypes.append("created")
            self.delegate?.itemCreated(pathType: pathType, path:path)
        }
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRemoved) != 0 {
            changeTypes.append("removed")
            self.delegate?.itemRemoved(pathType: pathType, path:path)
        }
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemModified) != 0 {
            changeTypes.append("modified")
            self.delegate?.itemModified(pathType: pathType, path:path)
        }
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRenamed) != 0 {
            changeTypes.append("renamed")
            self.delegate?.itemRenamed(pathType: pathType, path:path)
        }
        
        var extendEvents: [String] = []
        // extend event
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemInodeMetaMod) != 0 {
            extendEvents.append("Inode meta modified")
        }
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemFinderInfoMod) != 0 {
            extendEvents.append("Finder info modified")
        }
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemChangeOwner) != 0 {
            extendEvents.append("Changed owner")
        }
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemXattrMod) != 0 {
            extendEvents.append("Xattr modified")
        }
        
        var kernelEvents: [String] = []
        // kernel Events
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagUserDropped) != 0 {
            kernelEvents.append("User Dropped")
        }
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagKernelDropped) != 0 {
            kernelEvents.append("Kernel Dropped")
        }
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagMustScanSubDirs) != 0 {
            kernelEvents.append("Must scan sub directories")
        }
        if eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagHistoryDone) != 0 {
            kernelEvents.append("History done")
        }
        
        
        let descriptions = """
        - Path type: \(pathType)
        - Change type(s): \(changeTypes.joined(separator: " | "))
        - Extend event(s): \(extendEvents.joined(separator: " | "))
        - kernel event(s): \(kernelEvents.joined(separator: " | "))
        
        """
        return descriptions
    }
}

private func eventCallback(
    streamRef: ConstFSEventStreamRef,
    clientCallBackInfo: UnsafeMutableRawPointer?,
    numEvents: Int,
    eventPaths: UnsafeMutableRawPointer,
    eventFlags: UnsafePointer<FSEventStreamEventFlags>,
    eventIds: UnsafePointer<FSEventStreamEventId>
){
    guard let clientCallBackInfo = clientCallBackInfo else {
        print("eventCallback: clientCallBackInfo is nil")
        return
    }

    if numEvents == 0 {
        return
    }

    let monitor = Unmanaged<FolderMonitor>.fromOpaque(clientCallBackInfo).takeUnretainedValue()
    let paths = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue() as! [String]
    
    var eventInfoList: [(String, FSEventStreamEventFlags)] = []
    for i in 0..<numEvents {
        let path = paths[i]
        let flag = eventFlags[i]
        eventInfoList.append((path, flag))
    }
    
    for (path, flag) in eventInfoList {
        do {
            let eventType = try monitor.safeDescribeEvent(
                eventFlags: flag,
                path:path
            )
            print(
                """
                \(path):
                \(eventType)
                """
            )
        } catch {
            print("Parsing event failure: \(path) | error: \(error) | eventFlags: \(flag)")
        }
    }
}
