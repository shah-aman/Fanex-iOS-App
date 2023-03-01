//
//  AirDropViewModel.swift
//  fanex
//
//  Created by aman shah on 28/02/23.
//

import Foundation

import Combine

class AirDropService {
    
    static let shared = AirDropService()
    
    func getAirDrop() -> AnyPublisher<Airdrop, Error> {
        
        let request = URL(string: "https://jsonplaceholder.typicode.com/users")
        
        return ServiceManager.shared.callAPI(request!)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
