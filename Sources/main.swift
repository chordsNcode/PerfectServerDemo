import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import AppKit

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

func postKey(request: HTTPRequest, response: HTTPResponse) {
    do {
        guard let body = try JSONSerialization.jsonObject(with: Data(bytes: request.postBodyBytes!), options: .mutableLeaves) as? [String: Any],
            "sean" == body["username"] as? String else {
            
                response.appendBody(string: "Error: Forbidden")
                    .completed(status: .forbidden)
            return
        }

        try response.setBody(json: ["accessKey": UUID().uuidString])
                    .setHeader(.contentType, value: "application/json")
                    .completed()
    } catch {
        response.setBody(string: "500 Error")
                .completed(status: .internalServerError)
    }
}

func getImage(request: HTTPRequest, response: HTTPResponse) {
    guard let _ = request.header(.authorization) else {
        response.setBody(string: "Error: Unauthorized")
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
        response.setBody(string: "500 Error")
                .completed(status: .internalServerError)
    }
}

var routes = Routes()
routes.add(method: .post, uri: "v1/key", handler: postKey)
routes.add(method: .get, uri: "v1/image", handler: getImage)

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
