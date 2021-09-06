//
//  VideoRepositoryImpl.swift
//  Healthcare
//
//  Created by T T on 2021/06/12.
//

import Foundation
import Combine

enum VideoError: Error {
    case fail
}

struct TwilioGetTokenResponse: Codable {
    var token: String
}

class VideoRepositoryImpl: IVideoRepository {

    private var cancellables = Set<AnyCancellable>()

    func getToken(roomId: String ) -> Future<String, Error> {

        let params = ["roomId": roomId ]
        return Future<String, Error> { promise in
            CallableApi.call(as: TwilioGetTokenResponse.self, method: .twilioGetToken, params: params)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        break
                    }
                } receiveValue: { r in
                    if let r = r {
                        promise(.success(r.token))
                    } else {
                        promise(.failure(VideoError.fail))
                    }
                }.store(in: &self.cancellables)
        }
    }

}
