//
//  FlowClient.swift
//  MonsterMaker
//
//  Created by Hao Fu on 3/11/2022.
//

import FCL
import Flow
import Foundation
import UIKit
import Combine
import SafariServices

class FlowManager: NSObject ,ObservableObject {
    static let shared = FlowManager()

    @Published
    var pendingTx: String? = nil
    @Published var address: String = ""

    @Published var preAuthz: String = ""

    @Published var provider: FCL.Provider = fcl.currentProvider ?? .lilico

    @Published var env: Flow.ChainID = fcl.currentEnv

    @Published var walletList = FCL.Provider.getEnvCases()

    @MainActor
    @Published var isShowWeb: Bool = false

    @Published var isPresented: Bool = false

    @Published var isAccountProof: Bool?

    @Published var isUserMessageProof: Bool?

    @Published var accountLookup: String = ""

    @Published var currentObject: String = ""

    @Published var message: String = "foo bar"

    @Published var balance: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    func subscribeTransaction(txId: String) {
        Task {
            do {
                let id = Flow.ID(hex: txId)
                DispatchQueue.main.async {
                    self.pendingTx = txId
                }
                _ = try await id.onceSealed()
                await UIImpactFeedbackGenerator(style: .light).impactOccurred()
                DispatchQueue.main.async {
                    self.pendingTx = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.pendingTx = nil
                }
            }
        }
    }

    func setup() {
        let defaultProvider: FCL.Provider = .blocto
        let defaultNetwork: Flow.ChainID = .testnet
        let bloctoSDKAppId = "5595da5e-43a7-4001-956a-45bc5161e095"
        let accountProof = FCL.Metadata.AccountProofConfig(appIdentifier: "fanex app")
        let walletConnect = FCL.Metadata.WalletConnectConfig(urlScheme: "fanex-app://", projectID: "e41f3acff8f7ad5896b0b689e35f3526")
//        let bloctoWalletProvider = try BloctoWalletProvider(
//            bloctoAppIdentifier: bloctoSDKAppId,
//            window: nil,
//            network: .testnet,
//            logging: true
//        )
        let metadata = FCL.Metadata(appName: "fanex app",
                                    appDescription: "Expirence for a true fan",
                                    appIcon: URL(string: "https://ibb.co/prYRtJ3")!,
                                    location: URL(string: "https://571d-2401-4900-1c19-c93d-ac68-7414-aee7-32bc.in.ngrok.io")!,
                                    accountProof: accountProof,
                                    walletConnectConfig: walletConnect)
        
        fcl.config(metadata: metadata,
                   env: defaultNetwork,
                   provider: defaultProvider)
        

        fcl.config
            .put("0xFanex", value: "0x3d1a73afefe2d7f8")
        
        fcl.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { user in
                self.address = user?.addr.hex ?? ""
                if let user = user {
                    print("<==== Current User =====>")
                    print(user)
                    self.verifyAccountProof()
                } else {
                    print("<==== No User =====>")
                }
            }.store(in: &cancellables)

        fcl.$currentEnv
            .receive(on: DispatchQueue.main)
            .sink { env in
                self.env = env
                self.walletList = FCL.Provider.getEnvCases(env: env)
            }.store(in: &cancellables)

        fcl.$currentProvider
            .receive(on: DispatchQueue.main)
            .sink { provider in
                if let provider {
                    self.provider = provider
                }
            }.store(in: &cancellables)

//        fcl.delegate = self
        
           
    }
//    func authenticate() {
//            fcl.authenticate()
//                .receive(on: DispatchQueue.main)
//                .sink { result in
//                    print(result)
//                } receiveValue: { response in
//                    print(response)
//                }
//                .store(in: &cancellables)
//        }
    
    
//    func checkCollectionVault() async throws -> Bool {
//        guard let address = fcl.currentUser?.addr else {
//            throw FCLError.unauthenticated
//        }
//
//        do {
//            let result: Bool = try await fcl.query(script: MonsterMakerCadence.checkInit,
//                                                   args: [.address(address)]).decode()
//            return result
//        } catch {
//            print(error)
//            throw error
//        }
//    }
    func verifyAccountProof() {
        Task {
            do {
                let result = try await fcl.verifyAccountProof()
                print("verifyAccountProof ==> \(result)")
                await MainActor.run {
                    isAccountProof = result
                }
            } catch {
                print(error)
                await MainActor.run {
                    isAccountProof = false
                }
            }
        }
    }
    func authn() async {
        do {
            _ = try await fcl.reauthenticate()
        } catch {
            print(error)
        }
    }

}

extension FlowManager: FCLDelegate {
    func showLoading() {
//        ProgressHUD.show("Loading...")
        debugPrint("loading .......")
    }

    func hideLoading() {
//        ProgressHUD.dismiss()
        debugPrint("hope it gets connected")
    }
}
