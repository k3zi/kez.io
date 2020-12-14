import Fluent
import Vapor

struct GitController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let git = routes.grouped("git")
        git.post("push") { req -> Response in
            let object = try req.content.decode(GithubWebhookObject.self)
            let appDirectory = Config.shared.repoScanDirectory.appendingPathComponent(object.repository.name)
            shell(currentDirectoryURL: appDirectory, executableURL: .init(fileURLWithPath: "/usr/bin/git"), args: "pull")
            req.logger.debug("git: pulled into \(object.repository.name)")
            shell(currentDirectoryURL: appDirectory, executableURL: .init(fileURLWithPath: "/usr/bin/systemctl"), args: "restart", "--user", object.repository.name)
            return Response(status: .ok)
        }
    }

}
