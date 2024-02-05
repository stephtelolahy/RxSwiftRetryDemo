//
//  HTTPClient.swift
//  RxSwiftRetryDemo
//
//  Created by Hugues Telolahy on 05/02/2024.
//

import RxSwift
import Alamofire
import Foundation

/// HTTPClient is used to call Api and return DTO object in Reactive way
/// Builds `TargetTypeObject` needed for Moya request
/// Use `PluginType` to intercept request and perform common configurations
struct HTTPClient {

    private let baseUrl: String
    private let moya: MoyaProvider<TargetTypeObject>
    private let strongAuthErrorHandler: StrongAuthErrorHandling

    init(baseUrl: String,
         session: Session = MoyaProvider<TargetTypeObject>.defaultAlamofireSession(),
         plugins: [PluginType] = [],
         strongAuthErrorHandler: StrongAuthErrorHandling) {
        self.baseUrl = baseUrl
        self.strongAuthErrorHandler = strongAuthErrorHandler
        moya = MoyaProvider<TargetTypeObject>(session: session, plugins: plugins)
    }

    func request(path: String,
                 method: Moya.Method,
                 task: Task,
                 headers: [String: String]?) -> Single<Moya.Response> {
        let target = TargetTypeObject(baseURL: URL(string: baseUrl)!,
                                      path: path,
                                      method: method,
                                      task: task,
                                      headers: headers)
        let originalRequest = moya.rx.request(target)
        return autoRelogOnUnauthorized(originalRequest)
    }
}

private extension HTTPClient {
    /// Invoke login while unauthorized
    /// If succeed then retry request, else definitely fail
    func autoRelogOnUnauthorized(_ original: Single<Moya.Response>) -> Single<Moya.Response> {
        original.catch { error in
            guard strongAuthErrorHandler.isUnauthorizedError(error) else {
                return .error(error)
            }

            return loginOnError(error)
                .flatMap { _ in original.retry(1) }
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

            strongAuthErrorHandler.handleUnauthorizedError(error: error, callBack: callback)

            return Disposables.create()
        }
    }
}

/// Structure used to define the API specifications
///
private struct TargetTypeObject: TargetType {
    let baseURL: URL
    let path: String
    let method: Moya.Method
    let task: Task
    let headers: [String: String]?
    var sampleData: Data { Data() }
    let validationType: ValidationType = .successAndRedirectCodes
}

