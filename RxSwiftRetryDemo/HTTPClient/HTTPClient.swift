//
//  HTTPClient.swift
//  RxSwiftRetryDemo
//
//  Created by Hugues Telolahy on 05/02/2024.
//


import Moya
import RxSwift
import Alamofire
import Foundation

protocol HTTPClientErrorReporterProtocol: AnyObject {
    func reportError(_ error: Error, userInfo: [String: String])
}

/// HTTPClient is used to call Api and return DTO object in Reactive way
/// Builds `TargetTypeObject` needed for Moya request
/// Use `PluginType` to intercept request and perform common configurations
struct HTTPClient {

    private let baseUrl: String
    private let moya: MoyaProvider<TargetTypeObject>

    init(baseUrl: String,
         session: Session = MoyaProvider<TargetTypeObject>.defaultAlamofireSession(),
         plugins: [PluginType] = []) {
        self.baseUrl = baseUrl
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
        return moya.rx.request(target)
            .filterSuccessfulStatusCodes()
            .autoRelogOnUnauthorized()
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

