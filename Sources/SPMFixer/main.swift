//
//  main.swift
//  SPMFixer
//
//  Created by canius.chu on 2021/2/4.
//

import Foundation

let args = extractArgs(args: ProcessInfo.processInfo.arguments)

if args["archive"] != nil {
    try fixArchive()
    exit(0)
}

if let archivePath = args["archivePath"], args["clean"] != nil {
    try cleanArchive(archivePath: archivePath)
    exit(0)
}

if let name = args["unlink"], let project = args["project"] {
    let target = args["target"] ?? URL(fileURLWithPath: project).deletingPathExtension().lastPathComponent
    try unlink(projectPath: project, target: target, name: name)
    exit(0)
}

private func extractArgs(args: [String]) -> [String: String] {
    var ret = [String: String]()
    var currentKey: String?
    for arg in args {
        if arg.starts(with: "-") {
            if let key = currentKey {
                ret[key] = ""
            }
            currentKey = String(arg[arg.index(arg.startIndex, offsetBy: 1)..<arg.endIndex])
        } else if let key = currentKey {
            ret[key] = arg
            currentKey = nil
        }
    }
    if let key = currentKey {
        ret[key] = ""
    }
    return ret
}
