//
//  Platform.swift
//  LineCal
//
//  Created by tony on 2023/7/9.
//  Copyright © 2023 chengkaizone. All rights reserved.
//

import Foundation

public enum Platform : Int {
    case Android = 0
    case iOS = 1
    
    func getCode() -> String {
        switch self {
        case .Android:
            return "Android"
        case .iOS:
            return "iOS"
        }
    }
}
