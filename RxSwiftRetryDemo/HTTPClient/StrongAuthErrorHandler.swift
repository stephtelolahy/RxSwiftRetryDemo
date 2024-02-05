//
//  StrongAuthErrorHandler.swift
//  RxSwiftRetryDemo
//
//  Created by Hugues Telolahy on 05/02/2024.
//

typealias AuthenticationCallback = (Bool) -> Void

protocol StrongAuthErrorHandling {
    func isUnauthorizedError(_ error: Error) -> Bool
    func handleUnauthorizedError(_ error: Error, callBack: @escaping AuthenticationCallback)
}

extension Error {
    var isSessionExpirationError: Bool {
        // TODO: implement
        true
    }
}

struct StrongAuthErrorHandler: StrongAuthErrorHandling {

    func isUnauthorizedError(error: Error) -> Bool {
        true
    }

    func handleUnauthorizedError(_ error: Error, callBack: @escaping AuthenticationCallback) {
        callBack(true)
    }
}
