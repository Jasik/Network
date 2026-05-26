import Foundation
import Testing
@testable import Networking

@Suite("URLSessionHTTPClient")
struct URLSessionHTTPClientTests {

    // MARK: - Test fixtures

    struct TestResponse: Decodable, Sendable, Equatable {
        let message: String
    }

    struct TestRequest: HTTPRequest {
        typealias Response = TestResponse
        var baseURL = URL(string: "https://example.com")!
        var path = "test"
    }

    // MARK: - In-memory transport

    final class StubTransport: HTTPTransport, @unchecked Sendable {
        let result: Result<(Data, URLResponse), any Error>
        init(result: Result<(Data, URLResponse), any Error>) { self.result = result }

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            try result.get()
        }
    }

    private func makeResponse(status: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com/test")!,
            statusCode: status, httpVersion: nil, headerFields: nil
        )!
    }

    // MARK: - Tests

    @Test("2xx → decoded response")
    func successResponse() async throws {
        let payload = Data(#"{"message":"Hello"}"#.utf8)
        let transport = StubTransport(result: .success((payload, makeResponse(status: 200))))
        let client = URLSessionHTTPClient(transport: transport)

        let response = try await client.send(TestRequest())
        #expect(response == TestResponse(message: "Hello"))
    }

    @Test(
        "status code → ошибка",
        arguments: [
            (401, "unauthorized"),
            (403, "forbidden"),
            (404, "notFound"),
            (408, "timeout"),
            (500, "http"),
        ]
    )
    func statusMapping(code: Int, expected: String) async {
        let transport = StubTransport(result: .success((Data(), makeResponse(status: code))))
        let client = URLSessionHTTPClient(transport: transport)

        await #expect(throws: HTTPError.self) {
            try await client.send(TestRequest())
        }
    }

    @Test("URLError.timedOut → .timeout")
    func timeoutMapping() async {
        let transport = StubTransport(result: .failure(URLError(.timedOut)))
        let client = URLSessionHTTPClient(transport: transport)

        await #expect(throws: HTTPError.self) {
            try await client.send(TestRequest())
        }
    }
}
