# SpiderWeb
A spider web 🕸️  in your folder. (Monitor changes in a folder 😆)

## Features

Monitor changes in a folder, user can make some actions when items are created/renamed/removed/modified.

## Compatibility

This component requires macOS 10.15 or later.

## Installation

### Using Swift Package Manager：

Add the following to your `Package.swift`:

```swift
dependencies: [
  .package(url: https://github.com/HaxorusFans/SpiderWeb.git, from: "1.0.0")
]
```

### Manual Installation

1. Download the source files from this repository.

2. Drag and drop them into your Xcode project.

## Usage

```swift
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
```

```swift
struct ContentView: View {
    var t = TestClass(sw: SpiderWeb(location: "/your/path"))
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("Hello, world!")
            Button("weaveWeb") {
                t.sw?.weaveWeb()
            }
            Button("cleanWeb") {
                t.sw?.cleanWeb()
            }
        }
        .padding()
    }
}
```

### **App Store Submission Requirements**

For `SpiderWeb` to function properly in sandboxed environments (required for Mac App Store distribution), the host application must include these configurations:

#### **Entitlements File Configuration**

Add the following to your app's `.entitlements` file (typically `YourAppName.entitlements`):

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.files.bookmarks.app-scope</key>
<true/>
```

**Note for SpiderWeb Users(Spider-Men?)**:
These configurations must be implemented in the *host application*, not in the SpiderWeb package itself. See the example project for a complete implementation reference.
