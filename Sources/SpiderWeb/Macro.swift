//
//  File.swift
//  SpiderWeb
//
//  Created by salo on 26/3/2025.
//

import Foundation

//Developer can set "SWIFT_ACTIVE_COMPILATION_CONDITIONS = FORCE_DIRECT_MONITORING" in “Build Settings” to try to bypass the sandbox

#if FORCE_DIRECT_MONITORING
    let spiderWebSandboxEnabled = false
#else
    let spiderWebSandboxEnabled = true
#endif




