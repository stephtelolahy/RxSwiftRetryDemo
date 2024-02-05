//
//  StrongAuthErrorHandler.swift
//  RxSwiftRetryDemo
//
//  Created by Hugues Telolahy on 05/02/2024.
//

typealias AuthenticationCallback = (Bool) -> Void

extension Error {
    var isSessionExpirationError: Bool {
        // TODO: implement
        true
    }
}


struct StrongAuthErrorHandler {

    static let shared: Self = .init()

    func handleUnauthorizedError(callBack: @escaping AuthenticationCallback) {
        // TODO: implement
        callBack(true)
    }

}
