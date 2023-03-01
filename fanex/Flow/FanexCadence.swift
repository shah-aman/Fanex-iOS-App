//
//  FanexCadence.swift
//  fanex
//
//  Created by aman shah on 25/02/23.
//

import Foundation
class FanexCadence {
    
    static let initAccount = """
      import FanxToken from 0x3d1a73afefe2d7f8
      transaction {
          prepare(account: AuthAccount) {
              let vaultA <- FanxToken.createEmptyVault();
      
              account.save<@FanxToken.Vault>(<-vaultA, to: /storage/FanxTokenVault);
      
              // Deposit function exported
              let ReceiverRef = account.link<&FanxToken.Vault{FanxToken.Receiver}>(/public/FanxTokenReceiver, target: /storage/FanxTokenVault);
      
              let BalanceRef = account.link<&FanxToken.Vault{FanxToken.Balance}>(/public/FanxTokenBalance, target: /storage/FanxTokenVault)
      
              log("References Created")
          }
      }
"""
    static let checkInit =
        """
            import FanxToken from 0xFanex
            
           import FanxToken from 0x3d1a73afefe2d7f8

           pub fun main(address: Address): Bool {
               let vaultRef = getAccount(address)
                   .getCapability<&FanxToken.Vault{FanxToken.Balance}>(/public/FanxTokenBalance)
                   .check()

               return vaultRef
           }
        """
  static let getBalance =
          """
          import FanxToken from 0x3d1a73afefe2d7f8
          pub fun main(account: Address): UInt64 {
              let vaultRef = getAccount(account)
                  .getCapability(/public/FanxTokenBalance)
                  .borrow<&FanxToken.Vault{FanxToken.Balance}>()
                  ?? panic("Could not borrow account reference to the vault")
          
              return vaultRef.balance
          }
          """
   static let depositMoney =
"""
 import FanxToken from 0x3d1a73afefe2d7f8
      transaction(amount: UInt64) {
          prepare(account: AuthAccount) {
              let tempVault <- FanxToken.createNonEmptyVault(balance: amount);
      
              let vaultRef = account.borrow<&FanxToken.Vault>(from: /storage/FanxTokenVault)
                  ?? panic("Could not borrow reference of owner\'s vault");
              
              vaultRef.deposit(from: <-tempVault);
      
              log("Tokens despoited in account")
          }
      }
"""
    
    
    
}
