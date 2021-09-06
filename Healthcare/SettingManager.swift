//
//  SettingManager.swift
//  Healthcare
//
//  Created by Shin on 2021/06/28.
//

import Foundation

class SettingManager: NSObject {
    
    static let sharedInstance = SettingManager()
    
    var isTrainingPreparatory: Bool = true
}
