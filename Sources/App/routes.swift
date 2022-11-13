import Vapor

func routes(_ app: Application) throws {
    let webController = WebController()
    try app.register(collection: webController)
}
