import Fluent
import Vapor

struct GitController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let git = routes.grouped("git")
        git.post("push") { req -> Response in
            let object = try req.content.decode(GithubWebhookObject.self)
            guard let body = req.body.data else { return .init(status: .forbidden) }
            let bodyData = Data(buffer: body)
            let secret = Config.shared.githubWebhookSecret.data(using: .utf8)!
            let code = HMAC<SHA256>.authenticationCode(for: bodyData, using: SymmetricKey(data: secret))
            req.logger.info("git: code hex \(code.hex))")

            let appDirectoryURL = Config.shared.repoScanDirectoryURL.appendingPathComponent(object.repository.name)

            req.logger.info("\(object.repository.name) → git pulling in: \(appDirectoryURL)")
            shell(currentDirectoryURL: appDirectoryURL, executableURL: .init(fileURLWithPath: "/usr/bin/git"), args: "pull")
            req.logger.info("\(object.repository.name) → git pulled")

            req.logger.info("\(object.repository.name) → restarting")
            shell(currentDirectoryURL: appDirectoryURL, executableURL: .init(fileURLWithPath: "/usr/bin/systemctl"), args: "restart", "--user", object.repository.name)

            return Response(status: .ok)
        }
    }

}
