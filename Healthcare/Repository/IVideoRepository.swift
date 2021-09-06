//
//  IVideoRepository.swift
//  Healthcare
//
//  Created by T T on 2021/06/12.
//

import Combine

protocol IVideoRepository {

    func getToken(roomId: String ) -> Future<String, Error>
}
