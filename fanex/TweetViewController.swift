//
//  TweetViewController.swift
//  fanex
//
//  Created by aman shah on 28/02/23.
//

import Foundation
import UIKit
import SafariServices
import TweetView
import PopupDialog
protocol TweetControllerDismiss {
    func dismiss()
}
class TweetViewController : UIViewController {
//    let tweetTable =  UITableView()
    var tweetIds = ["1630493851990327298", "1630472423953891330","1630463076066525184"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTweetTableView()
        
    }
    var twitterVCDelegate : TweetControllerDismiss?
    
    func  createTweetTableView(){
       
//        tweetTable.delegate = self
//        tweetTable.dataSource = self
//        tweetTable.translatesAutoresizingMaskIntoConstraints = false
//        tweetTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        tweetTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        tweetTable.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        tweetTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        TweetView.prepare()
             
             let tweetView = TweetView(id:tweetIds[0])
             let width = view.frame.width - 32
            tweetView.frame = CGRect(x: 24, y: 24, width: width, height: 500)
            tweetView.delegate = self
//        tweetCell.contentView.addSubview(tweetView)
        self.view.addSubview(tweetView)
        tweetView.translatesAutoresizingMaskIntoConstraints = false
        tweetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tweetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tweetView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tweetView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//             self.view.addSubview()
       
      Task {

            tweetView.load()
        }
    
        
    }
    func createTweetCell(tweetId:String) -> UITableViewCell{
        let tweetCell = UITableViewCell()
    
    
           
        return tweetCell
    }
}
extension TweetViewController : TweetViewDelegate {
    func tweetView(_ tweetView: TweetView, didUpdatedHeight height: CGFloat) {
        tweetView.frame.size = CGSize(width: tweetView.frame.width, height: height)
//        tweetTable.reloadData()
    }

    func tweetView(_ tweetView: TweetView, shouldOpenURL url: URL) {
        debugPrint("do something and interact with this")
        debugPrint(url)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        TokenAmount.shared.totalToken += 50
        self.dismiss(animated: true)
        twitterVCDelegate?.dismiss()
        //create popup
       
    }
}

//extension TweetViewController : UITableViewDataSource , UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tweetIds.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return createTweetCell(tweetId: tweetIds[indexPath.row])
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//}
