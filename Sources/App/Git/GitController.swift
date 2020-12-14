import Fluent
import Vapor

struct GitController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let git = routes.grouped("git")
        git.post("push") { req -> Response in
            let object = try req.content.decode(GithubWebhookObject.self)
            guard let body = req.body.data else { return .init(status: .forbidden) }
            let bodyData = Data(buffer: body)
            let secret = SHA256.hash(data: Config.shared.githubWebhookSecret.data(using: .utf8)!.base64EncodedData())
            let code = HMAC<SHA256>.authenticationCode(for: bodyData, using: SymmetricKey(data: secret))
            req.logger.debug("git: code \(code.description))")
            req.logger.debug("git: code hex \(code.hex))")
            req.logger.debug("git: code hexEncodedString \(code.hexEncodedString()))")
            let appDirectoryURL = Config.shared.repoScanDirectory.appendingPathComponent(object.repository.name)
            req.logger.debug("git: pulling into \(object.repository.name) (\(appDirectoryURL))")
            shell(currentDirectoryURL: appDirectoryURL, executableURL: .init(fileURLWithPath: "/usr/bin/git"), args: "pull")
            req.logger.debug("git: pulled into \(object.repository.name)")
            shell(currentDirectoryURL: appDirectoryURL, executableURL: .init(fileURLWithPath: "/usr/bin/systemctl"), args: "restart", "--user", object.repository.name)
            return Response(status: .ok)
        }
    }

}
