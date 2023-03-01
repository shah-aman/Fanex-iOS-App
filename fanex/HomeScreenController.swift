////
////  homeScreenController.swift
////  fanex
////
////  Created by aman shah on 25/02/23.
////
//
//import Foundation
//import UIKit
//class HomeScreenController :BaseViewController {
//
//    lazy var button: UIButton = {
//        let button = UIButton()
//        button.setTitle("Push new VC", for: .normal)
//        button.addTarget(self, action: #selector(handeAction(_:)), for: .touchUpInside)
//        button.backgroundColor = .systemBlue
//        button.layer.cornerRadius = 5
//
//        button.titleEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
//        button.constrainWidth(constant: 150)
//        return button
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//    }
//
//    init(showPushButton: Bool = false) {
//        super.init(nibName: nil, bundle: nil)
//
//        if showPushButton {
//            setupButton()
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        toogleTabbar(hide: false)
//    }
//
//    func setupButton() {
//
//        view.addSubview(button)
//        button.centerInSuperview()
//    }
//
//    @objc
//    func handeAction(_ sender: UIButton) {
//        let newVC = PushViewController()
//        navigationController?.navigationBar.tintColor = .black
//        navigationController?.pushViewController(newVC, animated: true)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}


import UIKit
import FCL
import Combine
import EKTabBarController
class HomeScreenController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    @IBOutlet weak var loadingImage: UIImageView!
    
    func pushTabViewController () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let actionController = storyboard.instantiateViewController(withIdentifier: "ActionsController") 
//        self.present(vc, animated: true)
//        let actionController = ActionsContoller()
//        viewController1.view.backgroundColor = .black
        
        let actionsViewItem = EKControllerItem(tabBarButtonItem: UITabBarItem(title: "Scan", image: UIImage(systemName: "qrcode.viewfinder")
, selectedImage: UIImage(systemName: "qrcode.viewfinder")
) , viewController:actionController )
        
        let tweetController = TweetViewController()
//        viewController1.view.backgroundColor = .black
        
        let tweetViewItem = EKControllerItem(tabBarButtonItem: UITabBarItem(title: "Social Media", image: UIImage(systemName: "lightbulb")
, selectedImage: UIImage(systemName: "lightbulb.fill")
) , viewController:tweetController )
        
        let viewController2 = UIViewController()
        viewController2.view.backgroundColor = .red
        let profileStoryBoard = UIStoryboard(name: "ProfileView", bundle: nil)
        let profileVc = profileStoryBoard.instantiateViewController(withIdentifier: "ProfileViewController")
        let profileItem = EKControllerItem(tabBarButtonItem: UITabBarItem(title: "Scan", image: UIImage(systemName: "person.crop.circle") , selectedImage: UIImage(systemName: "person.crop.circle.fill")) , viewController: profileVc)
       
        let tabBarController = EKTabBarController(controllerItems: [actionsViewItem, tweetViewItem,profileItem], cornerRadius: 20, backgroundColor: .white.withAlphaComponent(0.5))
        self.navigationController?.pushViewController(tabBarController, animated: true)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        let intialiseScreen = UIImage.gifImageWithName("waiting-setting-account")
        loadingImage.image =  intialiseScreen
        Task {
            do {
                let txId = try await fcl.mutate(cadence: FanexCadence.initAccount)
                print("txId ==> \(txId.hex)")
                FlowManager.shared.subscribeTransaction(txId: txId.hex)
                FlowManager.shared.$pendingTx
                    .receive(on: DispatchQueue.main)
                    .sink { txId in
                        if txId == nil {
                            //navigate to other screen
                            self.pushTabViewController()
                            debugPrint("now its a good time to navigate from this screen")
                        }
                        
                    }.store(in: &cancellables)
            } catch {
                print(error)
            }
        }
      
//        FlowManager.shared.$address
//            .receive(on: DispatchQueue.main)
//            .sink { user in
//                self.address = user
//            }.store(in: &cancellables)
//        tabBar.tintColor = UIColor(white: 0.75, alpha: 1)
//
//        viewControllers = (1...3).map { "Tab\($0)" }.map {
//            let selected = UIImage(named: $0 + "_Large")!
//            let normal = UIImage(named: $0 + "_Small")!
//            let controller = storyboard!.instantiateViewController(withIdentifier: $0)
//            controller.title = $0
//            controller.view.backgroundColor = UIColor(named: $0)
//            controller.floatingTabItem = FloatingTabItem(selectedImage: selected, normalImage: normal)
//            return controller
//        }
        
    }
    
}
