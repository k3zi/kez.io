import Fluent
import Vapor

struct GitController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let git = routes.grouped("git")
        git.post("push") { req -> Response in
            let object = try req.content.decode(GithubWebhookObject.self)
            let appDirectoryURL = Config.shared.repoScanDirectory.appendingPathComponent(object.repository.name)
            req.logger.debug("git: pulling into \(object.repository.name) (\(appDirectoryURL))")
            shell(currentDirectoryURL: appDirectoryURL, executableURL: .init(fileURLWithPath: "/usr/bin/git"), args: "pull")
            req.logger.debug("git: pulled into \(object.repository.name)")
            shell(currentDirectoryURL: appDirectoryURL, executableURL: .init(fileURLWithPath: "/usr/bin/systemctl"), args: "restart", "--user", object.repository.name)
            return Response(status: .ok)
        }
    }

}
