//
//  ProfileViewController.swift
//  fanex
//
//  Created by aman shah on 28/02/23.
//

import Foundation
import UIKit
import Combine
class ProfileViewController : UIViewController {
    private var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var nftTableview: UITableView!
    @IBOutlet weak var optionView : UIView!
    @IBOutlet weak var optionButton : UIButton!
    @IBOutlet weak var profileImage : UIImageView!
    @IBOutlet weak var walletBalance : UILabel!
    @IBOutlet weak var userName : UILabel!
    @IBOutlet weak var redeemedCoins : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nftTableview.register(NFTImageCell.self, forCellReuseIdentifier: "NFTImageCell")
        nftTableview.dataSource = self
        nftTableview.delegate = self
        profileImage.layer.cornerRadius = 63
        optionView.layer.cornerRadius = 25
        FlowManager.shared.$address
            .receive(on: DispatchQueue.main)
            .sink { user in
                if user != "" {
                    self.userName.text = user
                }
                
            }.store(in: &cancellables)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        walletBalance.text = String(TokenAmount.shared.totalToken)
        redeemedCoins.text = String(TokenAmount.shared.totalNfts)
    }
}
extension ProfileViewController :  UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return  1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let nftCell = nftTableview.dequeueReusableCell(withIdentifier: "NFTImageCell", for: indexPath) as? NFTImageCell else  {
            return NFTImageCell()
        }
//        nftCell.nftImage.image = UIImage(named: "superFan NFt")
//        nftCell.nftImage.layer.cornerRadius = 25
//        nftImage.load(url: URL(string: "https://i.ibb.co/bgCWhDM/super-Fan-NFt.png")!)
       
    return nftCell
    }
    
    
    
}
 
