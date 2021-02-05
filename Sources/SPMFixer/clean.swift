//
//  clean.swift
//  SPMFixer
//
//  Created by canius.chu on 2021/2/5.
//

import Foundation
import PathKit

func cleanArchive(archivePath: String) throws {
    guard let appPath = try (Path(archivePath) + "Products/Applications").children().first(where: { $0.extension == "app" }) else { return }
    for framework in try (appPath + "Frameworks").children() where framework.extension == "framework" {
        let binary = framework + framework.lastComponentWithoutExtension
        let (code, ret) = shell("file", binary.string)
        if code != 0 { fatalError("Failed to exec shell: file \(binary), code = \(code)") }
        if ret?.contains("Mach-O 64-bit dynamically linked shared library arm64") == true { continue }
        print("removing \(framework.lastComponent)")
        try framework.delete()
    }
    for plugin in try (appPath + "PlugIns").children() where plugin.extension == "framework" {
        try plugin.delete()
    }
}

@discardableResult
func shell(_ args: String...) -> (Int32, String?) {
    let pipe = Pipe()
    let task = Process()
    task.standardOutput = pipe
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return (task.terminationStatus, String(data: data, encoding: String.Encoding.utf8))
}
