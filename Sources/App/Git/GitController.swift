import Fluent
import Vapor

struct GitController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let git = routes.grouped("git")
        git.post("push") { req -> Response in
            let object = try req.content.decode(GithubWebhookObject.self)

            // Get raw body of request.
            guard let bodyBuffer = req.body.data else {
                return .init(status: .badRequest)
            }
            let bodyData = Data(buffer: bodyBuffer)

            // Get signature of body.
            guard let githubSignature = req.headers.first(name: "X-Hub-Signature-256") else {
                return .init(status: .badRequest)
            }

            // Get data of secret from config.
            guard let secret = Config.shared.githubWebhookSecret.data(using: .utf8) else {
                return .init(status: .internalServerError)
            }

            let mac = HMAC<SHA256>.authenticationCode(for: bodyData, using: SymmetricKey(data: secret))

            req.logger.info("webhook → checking \(mac.hex) == \(githubSignature)")
            guard mac.hex == githubSignature else {
                return .init(status: .forbidden)
            }

            let appDirectoryURL = Config.shared.repoScanDirectoryURL.appendingPathComponent(object.repository.name)

            // Pull latest code with git.
            req.logger.info("\(object.repository.name) → git pulling in: \(appDirectoryURL)")
            shell(currentDirectoryURL: appDirectoryURL, executableURL: .init(fileURLWithPath: "/usr/bin/git"), args: "pull")
            req.logger.info("\(object.repository.name) → git pulled")

            // Restart relevant service.
            req.logger.info("\(object.repository.name) → restarting")
            shell(currentDirectoryURL: appDirectoryURL, executableURL: .init(fileURLWithPath: "/usr/bin/systemctl"), args: "restart", "--user", object.repository.name)

            return Response(status: .ok)
        }
    }

}
