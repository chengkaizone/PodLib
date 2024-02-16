//
//  Build.swift
//  LineCal
//
//  Created by tony on 2023/7/9.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation

public class Build {
    
    // 品牌
    static let BRAND = "iPhone"
    // 型号
    static let MODEL = myModel()
    
    class func myModel() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
}
