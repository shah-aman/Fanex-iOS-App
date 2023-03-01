//
//  AirdropViewModel.swift
//  fanex
//
//  Created by aman shah on 28/02/23.
//

import Foundation

import Combine

class AirdropViewModel {
  
    var airdrop : Airdrop?
    var airdropStatus = CurrentValueSubject<Airdrop, Never>(Airdrop(status: ""))
    
    func getAirdrop() {
        
        let _ = AirDropService.shared.getAirDrop()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { (_) in
                
            }) { [weak self] (_airdrop) in
                
                guard let `self` = self else {
                    return
                }
                
                self.airdrop = _airdrop
                self.airdropStatus.send(_airdrop)
        }
    }
    
//    func getSearchResult(_ str: String) {
//
//        let arr = arrUserData.filter({($0.name?.lowercased().contains(str) ?? false)})
//        self.userData.send((str.trimmingCharacters(in: .whitespacesAndNewlines) != "") ? arr : arrUserData)
//    }
}
