//
//  RepositorySearchErrorTests.swift
//  GitHubRepAppTests
//

import Foundation
import Testing
@testable import GitHubRepApp

@Suite("RepositorySearchError のローカライズメッセージ")
struct RepositorySearchErrorTests {

    @Test("各ケースに人間向けメッセージが用意されている", arguments: [
        RepositorySearchError.invalidQuery,
        .network(URLError(.notConnectedToInternet)),
        .decoding,
        .rateLimitExceeded,
        .server(statusCode: 500),
        .unknown
    ])
    func eachCaseHasDescription(_ error: RepositorySearchError) {
        let message = error.errorDescription
        #expect(message != nil)
        #expect(message?.isEmpty == false)
    }
}
