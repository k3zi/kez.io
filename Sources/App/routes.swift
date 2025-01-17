import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("git") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: GitController())
    try app.register(collection: TodoController())
}
