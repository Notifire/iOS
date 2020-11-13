//
//  NotifireAPIManagerMocking.swift
//  Notifire Mock
//
//  Created by David Bielik on 13/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol NotifireAPIManagerMocking {}

extension NotifireAPIManagerMocking {
    func returnSuccessAfter<Response: Decodable>(duration: TimeInterval = 1.5, completion: @escaping NotifireAPIBaseManager.Callback<Response>, response: Response) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion(.success(response))
        }
    }

    func returnPlainSuccessResponseAfter(duration: TimeInterval = 1.5, completion: @escaping NotifireAPIBaseManager.Callback<NotifireAPIPlainSuccessResponse>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion(.success(NotifireAPIPlainSuccessResponse(success: true)))
        }
    }

    func returnErrorResponseAfter<Response: Decodable>(duration: TimeInterval = 1.5, error: NotifireAPIError = NotifireAPIError.unknown, completion: @escaping NotifireAPIBaseManager.Callback<Response>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            completion(.error(error))
        }
    }
}
