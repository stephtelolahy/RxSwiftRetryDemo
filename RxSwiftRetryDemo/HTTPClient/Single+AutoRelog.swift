//
//  Single+AutoRelog.swift
//  RxSwiftRetryDemo
//
//  Created by Hugues Telolahy on 05/02/2024.
//

import Moya
import Alamofire
import RxSwift


extension PrimitiveSequence where Trait == SingleTrait, Element == Response {

    /// Invoke login while unauthorized
    /// If succeed then retry request, else definitely fail
    func autoRelogOnUnauthorized() -> Single<Element> {
        self.catch { error in
            guard error.isSessionExpirationError else {
                return .error(error)
            }

            return self.loginOnError(error)
                .flatMap { _ in self.retry(1) }
        }
    }

    func loginOnError(_ error: Error) -> Single<Void> {
        Single.create { observer in
            let callback: AuthenticationCallback = { success in
                if success {
                    observer(.success(Void()))
                } else {
                    observer(.failure(error))
                }
            }

            StrongAuthErrorHandler.shared.handleUnauthorizedError(callBack: callback)

            return Disposables.create()
        }
    }
}
