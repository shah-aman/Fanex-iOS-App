//
//  ViewController.swift
//  fanex
//
//  Created by aman shah on 25/02/23.
//

import UIKit
import FCL
import Combine
class ViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    var address = ""
    var verifyUser = false
    var navigated = false
    @IBOutlet weak var tempButtonWalletConnect: UIButton!
    @IBOutlet weak var walletConnetLabel: UILabel!
    @IBOutlet weak var splashScreenLogo: UIImageView!
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
  
      
//        if (address != ""){
//            self.navigateToHome()
//
//        }
//        debugPrint(FlowManager.shared.address)
//
//        debugPrint(fcl.currentUser)
//        if let userWalletAddress = fcl.currentUser?.address {
//            // do some stuff here.
//            debugPrint("Dont cry it works now ", fcl.currentUser?.address)
//        }
//        let accountProofData = FCLAccountProofData(
//            appId: "fanex.app",
//            nonce: "75f8587e5bd5f9dcc9909d0dae1f0ac5814458b2ae129620502cb936fde7120a" // minimum 32-byte random nonce as a hex string.
//        )
//        Task {
//            do {
//                let address = try await fcl.authanticate(accountProofData: accountProofData)
//            } catch {
//                // handle error here
//            }
//        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let splashScreen = UIImage.gifImageWithName("fanex logo")
        splashScreenLogo.image =  splashScreen
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                 self.navigateToHome()
//             }
        tempButtonWalletConnect.addTarget(self, action: #selector(connectWallet), for: .touchDown)
//        fcl.delegate = self
        createUI()
        FlowManager.shared.$address
            .receive(on: DispatchQueue.main)
            .sink { user in
                if user != "" {
                    self.address = user
                    self.navigateToHome()
                }
                
            }.store(in: &cancellables)
    }
    @objc func connectWallet()  {
//        do {
//            try  await fcl.authenticate()
//        } catch {
//            print("Unexpected account didnot connect: \(error)")
//        }
//        fcl.openDiscovery()
        Task {
            do {
//                    try fcl.changeProvider(provider: , env: fcl.currentEnv)
                _ = try await fcl.authenticate()
            } catch {
                print(error)
            }
        }
//        fcl.closeDiscoveryIfNeed {
//
//        }
//        try await fcl.authenticate()
//        do{
//            let walletObject = try await fcl.authenticate()
//            debugPrint(walletObject)
//        }catch {
//            debugPrint("there was a error authenticating",error)
//        }
 
        
    }
    private func navigateToHome() {
        // Instantiate the home screen view controller from the storyboard
     
        // Set the navigation controller's root view controller to the home screen view controller
        
        
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : HomeScreenController = storyboard.instantiateViewController(withIdentifier: "HomeScreenController") as! HomeScreenController
//
        self.navigationController?.pushViewController(vc, animated: true)
//        let navigationController = UINavigationController(rootViewController: vc)
//        self.performSegue(withIdentifier: "homeNavigation", sender: self)
//        self.(navigationController, animated: true)

        
    }

    private func createUI(){
        walletConnetLabel.text =  "Click To connect".uppercased()
        walletConnetLabel.addCharacterSpacing(kernValue: 2.5)
        
        
    }
}

extension ViewController : FCLDelegate {
    func showLoading() {
        ProgressHUD.show("Loading...")
    }

    func hideLoading() {
        ProgressHUD.dismiss()
    }
}
