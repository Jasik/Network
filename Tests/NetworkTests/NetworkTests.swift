import XCTest
@testable import Network

final class NetworkTests: XCTestCase {
    var client: URLSessionHTTPClient!
    var session: URLSession!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        client = URLSessionHTTPClient(session: session, builder: URLRequestBuilder())
    }
    
    override func tearDown() {
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.stubResponse = nil
        MockURLProtocol.stubError = nil
        session.invalidateAndCancel()
        session = nil
        client = nil
        super.tearDown()
    }
    
    func testSendRequestSuccess() {
        let expectation = self.expectation(description: "Successful Request")
        
        let jsonResponse = """
            {"message": "Hello"}
            """.data(using: .utf8)
        let url = URL(string: "https://example.com/test")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        MockURLProtocol.stubResponseData = jsonResponse
        MockURLProtocol.stubResponse = httpResponse
        MockURLProtocol.stubError = nil
        
        let request = TestRequest()
        
        client.send(request) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, TestResponse(message: "Hello"))
            case .failure(let error):
                XCTFail("Expected success, but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSendRequestUnauthorized() {
        let expectation = self.expectation(description: "Unauthorized Request")
        
        let jsonResponse = """
            {"error": "Unauthorized"}
            """.data(using: .utf8)
        let url = URL(string: "https://example.com/test")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
        
        MockURLProtocol.stubResponseData = jsonResponse
        MockURLProtocol.stubResponse = httpResponse
        MockURLProtocol.stubError = nil
        
        let request = TestRequest()
        
        client.send(request) { result in
            switch result {
            case .success:
                XCTFail("Expected unauthorized error, but got success")
            case .failure(let error):
                switch error {
                case .unauthorized(let response, _):
                    XCTAssertEqual(response.statusCode, 401)
                default:
                    XCTFail("Expected unauthorized error, got \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSendRequestNetworkError() {
        let expectation = self.expectation(description: "Network Error")
        
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.stubResponse = nil
        MockURLProtocol.stubError = networkError
        
        let request = TestRequest()
        
        client.send(request) { result in
            switch result {
            case .success:
                XCTFail("Expected network error, but got success")
            case .failure(let error):
                switch error {
                case .networkError(let err as NSError):
                    XCTAssertEqual(err.code, NSURLErrorNotConnectedToInternet)
                default:
                    XCTFail("Expected network error, got \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    // MARK: - Async/Await Tests
    
    func testAsyncSendRequestSuccess() async {
        let jsonResponse = """
            {"message": "Hello"}
            """.data(using: .utf8)
        let url = URL(string: "https://example.com/test")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        MockURLProtocol.stubResponseData = jsonResponse
        MockURLProtocol.stubResponse = httpResponse
        MockURLProtocol.stubError = nil
        
        let request = TestRequest()
        
        let result = await client.send(request)
        
        switch result {
        case .success(let response):
            XCTAssertEqual(response, TestResponse(message: "Hello"))
        case .failure(let error):
            XCTFail("Expected success, but got error: \(error)")
        }
    }
    
    func testAsyncSendRequestUnauthorized() async {
        let jsonResponse = """
            {"error": "Unauthorized"}
            """.data(using: .utf8)
        let url = URL(string: "https://example.com/test")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
        
        MockURLProtocol.stubResponseData = jsonResponse
        MockURLProtocol.stubResponse = httpResponse
        MockURLProtocol.stubError = nil
        
        let request = TestRequest()
        
        let result = await client.send(request)
        
        switch result {
        case .success:
            XCTFail("Expected unauthorized error, but got success")
        case .failure(let error):
            switch error {
            case .unauthorized(let response, _):
                XCTAssertEqual(response.statusCode, 401)
            default:
                XCTFail("Expected unauthorized error, got \(error)")
            }
        }
    }
    
    func testAsyncSendRequestNetworkError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.stubResponse = nil
        MockURLProtocol.stubError = networkError
        
        let request = TestRequest()
        
        let result = await client.send(request)
        
        switch result {
        case .success:
            XCTFail("Expected network error, but got success")
        case .failure(let error):
            switch error {
            case .networkError(let err as NSError):
                XCTAssertEqual(err.code, NSURLErrorNotConnectedToInternet)
            default:
                XCTFail("Expected network error, got \(error)")
            }
        }
    }
}

struct TestResponse: Decodable, Equatable {
    let message: String
}

struct TestRequest: HTTPRequest {
    typealias Response = TestResponse
    var baseURL: URL? = URL(string: "https://example.com")
    var path: String = "test"
    var method: HTTPMethod = .get
    var headerFields: HTTPHeaderFields = .defaultHeaders()
    var query: EmptyParameters? = nil
    var body: EmptyParameters? = nil
    var decoder: JSONDecoder = JSONDecoder()
    
    func parse(data: Data, response: HTTPURLResponse) throws -> TestResponse {
        return try decoder.decode(TestResponse.self, from: data)
    }
}

class MockURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var stubResponse: HTTPURLResponse?
    static var stubError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.stubError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.stubResponse {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.stubResponseData {
                self.client?.urlProtocol(self, didLoad: data)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {}
}
