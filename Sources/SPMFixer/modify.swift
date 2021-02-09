//
//  File.swift
//  
//
//  Created by canius.chu on 2021/2/9.
//

import Foundation
import PathKit
import XcodeProj

func modifyRC(projectPath: String) throws {
    let path = Path(projectPath)
    let proj = try XcodeProj(path: path)
    guard let pandaTarget = proj.pbxproj.targets(named: "Panda").first else { return }
    pandaTarget.append(configuration: "Release", settings: [
        "PRODUCT_BUNDLE_IDENTIFIER": "com.farfetch.china.discover.release-candidate",
        "CUSTOM_BUNDLE_DISPLAY_NAME": "PandaRC",
    ])
    guard let pushTarget = proj.pbxproj.targets(named: "RichPushNotifications").first else { return }
    pushTarget.append(configuration: "Release", settings: [
        "PRODUCT_BUNDLE_IDENTIFIER": "com.farfetch.china.discover.release-candidate.richpushnotifications"
    ])
    
    try proj.write(path: path)
}

extension PBXTarget {
    
    func append(configuration: String, settings: [String: String]) {
        guard let config = buildConfigurationList?.configuration(name: configuration) else { return }
        var buildSettings = config.buildSettings
        settings.forEach { buildSettings[$0.key] = $0.value }
        config.buildSettings = buildSettings
    }
}
