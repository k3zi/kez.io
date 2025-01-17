import Foundation
import Vapor

struct Config: Decodable {

    static var shared: Config = {
        let directory = DirectoryConfiguration.detect().workingDirectory
        var configURL = URL(fileURLWithPath: directory, isDirectory: true)
        configURL.appendPathComponent("config.json")
        let data = try! Data(contentsOf: configURL)
        return try! JSONDecoder().decode(Config.self, from: data)
    }()

    private init() { fatalError() }

    let repoScanDirectory: String
    var repoScanDirectoryURL: URL { URL(fileURLWithPath: repoScanDirectory) }
    let githubWebhookSecret: String

}
