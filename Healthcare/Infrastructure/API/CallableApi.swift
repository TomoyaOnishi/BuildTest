//
//  CallableApi.swift
//  Healthcare
//
//  Created by T T on 2021/06/12.
//

import Foundation
import Firebase
import Combine

class CallableApi {

    enum Methods {
        case twilioGetToken

        var string: String {

            switch self {
            case .twilioGetToken:
                return "callable-twilio-getToken"
            }
        }

    }

    enum CallableApiError: Error {
        case decodingError
    }

    static func getFunctions() -> Functions {
        let functions = Functions.functions(region: "asia-northeast1")
        // functionsをローカル実行する際に利用
        //        functions.useEmulator(withHost: "http://0.0.0.0", port: 5000)
        return functions
    }

    private static let decorder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()

    static func call<T: Decodable>(as type: T.Type, method: Methods, params: [String: Any]) -> Future<T?, Error> {
        return Future<T?, Error> { promise in
            getFunctions().httpsCallable(method.string).call(params) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                } else {
                    var data: T?
                    if let dict = result?.data as? [String: Any],
                       let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                        data = try? JSONDecoder().decode(T.self, from: jsonData)
                    } else {
                        data = nil
                    }
                    guard let d = data else {
                        promise(.failure(CallableApiError.decodingError))
                        return
                    }
                    promise(.success(d))
                    return
                }
            }
        }
    }
}
