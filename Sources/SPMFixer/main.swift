import Foundation

guard let productPath = ProcessInfo.processInfo.environment["BUILT_PRODUCTS_DIR"] else {
    exit(0)
}
var xcURLs = [URL]()
let productURL = URL(fileURLWithPath: productPath)
var artifactsURL = productURL
for _ in 0..<6 {
    artifactsURL.deleteLastPathComponent()
}
artifactsURL.appendPathComponent("SourcePackages")
artifactsURL.appendPathComponent("artifacts")

guard let enumerator = FileManager.default.enumerator(at: artifactsURL, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsSubdirectoryDescendants) else {
    exit(0)
}

for case let folder as URL in enumerator {
    guard let sub_enumerator = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsSubdirectoryDescendants) else {
        continue
    }
    for case let xcURL as URL in sub_enumerator {
        if xcURL.pathExtension == "xcframework" {
            xcURLs.append(xcURL)
        }
    }
}

for xcURL in xcURLs {
    guard let libURL = selectDeviceFramework(for: xcURL) else { continue }
    let targetURL = productURL.appendingPathComponent(libURL.lastPathComponent)
    print("copy from: \(libURL) to: \(targetURL)")
    try? FileManager.default.removeItem(at: targetURL)
    try FileManager.default.copyItem(at: libURL, to: targetURL)
}

func selectDeviceFramework(for url: URL) -> URL? {
    guard let dict = NSDictionary(contentsOf: url.appendingPathComponent("Info.plist")) else { return nil }
    guard let libs = dict["AvailableLibraries"] as? NSArray else { return nil }
    for case let lib as NSDictionary in libs {
        if lib["SupportedPlatformVariant"] as? String != "simulator" {
            if let libIdentifier = lib["LibraryIdentifier"] as? String, let libPath = lib["LibraryPath"] as? String {
                return url.appendingPathComponent(libIdentifier).appendingPathComponent(libPath)
            }
        }
    }
    return nil
}
