// swiftlint:disable force_try
import Foundation
import MongoSwift
import MockUtils
@testable import StitchCoreSDK

public struct StubAuthRoutes: StitchAuthRoutes {
    public var sessionRoute: String = ""

    public var profileRoute: String = ""

    public var baseAuthRoute: String = ""

    public func authProviderRoute(withProviderName providerName: String) -> String {
        return ""
    }

    public func authProviderLoginRoute(withProviderName providerName: String) -> String {
        return ""
    }

    public func authProviderLinkRoute(withProviderName providerName: String) -> String {
        return ""
    }
}

public final class StubStitchRequestClient: StitchRequestClient {
    public let baseURL: String

    public let transport: Transport

    public let defaultRequestTimeout: TimeInterval

    public init() {
        baseURL = ""
        transport = MockTransport()
        defaultRequestTimeout = 0
    }

    public func doRequest(_ stitchReq: StitchRequest) throws -> Response {
        return Response.init(statusCode: 500, headers: [:], body: nil)
    }

    public func doStreamRequest(_ stitchReq: StitchRequest, delegate: SSEStreamDelegate? = nil) throws -> RawSSEStream {
        return FoundationHTTPSSEStream()
    }
}

public final class MockCoreStitchAuth<TStitchUser>: CoreStitchAuth<TStitchUser> where TStitchUser: CoreStitchUser {
    // concrete classes in Swift are a little tricky to mock. we can't do a true mock, since super.init must always be
    // called in Swift. This init makes sure that the super init runs without an error.
    public init() {
        self.getAuthInfoMock.doReturn(result: nil) // necessary for init() to run without failing
        try! super.init(requestClient: StubStitchRequestClient.init(),
                        authRoutes: StubAuthRoutes.init(),
                        storage: MemoryStorage(),
                        startRefresherThread: false)
        self.getAuthInfoMock.clearStubs()
        self.getAuthInfoMock.clearInvocations()
    }

    public var isLoggedInMock = FunctionMockUnit<Bool>()
    public override var isLoggedIn: Bool {
        return isLoggedInMock.run()
    }

    public var getAuthInfoMock = FunctionMockUnit<AuthInfo?>()
    public override var activeUserAuthInfo: AuthInfo? {
        get { return getAuthInfoMock.run() }
        set {}
    }

    public var refreshAccessTokenMock = FunctionMockUnit<Void>()
    public override func refreshAccessToken() {
        return refreshAccessTokenMock.run()
    }
}
