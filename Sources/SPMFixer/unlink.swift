//
//  unlink.swift
//  SPMFixer
//
//  Created by canius.chu on 2021/2/4.
//

import Foundation
import PathKit
import XcodeProj

func unlink(projectPath: String, target: String, name: String) throws {
    let path = Path(projectPath)
    let proj = try XcodeProj(path: path)
    guard let target = proj.pbxproj.targets(named: target).first else { return }
    target.packageProductDependencies.removeAll(where: { $0.productName == name })
    
    guard let phase = target.buildPhases.compactMap({ $0 as? PBXFrameworksBuildPhase }).first else { return }
    guard var files = phase.files else { return }
    files.removeAll(where: { $0.product?.productName == name })
    phase.files = files
    
    try proj.write(path: path)
}
