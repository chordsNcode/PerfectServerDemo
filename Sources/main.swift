import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import AppKit

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

func getKey(request: HTTPRequest, response: HTTPResponse) {
    do {
        guard request.param(name: "username") == "sean" else {
            response.appendBody(string: "error")
                    .completed(status: .forbidden)
            return
        }

        try response.setBody(json: ["accessKey": UUID().uuidString])
                    .setHeader(.contentType, value: "application/json")
                    .completed()
    } catch {
        response.setBody(string: "Error")
                .completed(status: .internalServerError)
    }
}

func getImage(request: HTTPRequest, response: HTTPResponse) {
    guard let _ = request.header(.authorization) else {
        response.setBody(string: "Error")
                .completed(status: .unauthorized)
        return
    }

    do {
        let image = File("webroot/perfect.png")
        let data = try image.readSomeBytes(count: image.size)

        response.setBody(bytes: data)
                .setHeader(.contentType, value: "image/png")
                .completed()


    } catch {
        response.setBody(string: "Error")
                .completed(status: .internalServerError)
    }
}

var routes = Routes()
routes.add(method: .get, uri: "key", handler: getKey)
routes.add(method: .get, uri: "image", handler: getImage)

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
