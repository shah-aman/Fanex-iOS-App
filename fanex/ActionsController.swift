//
//  ActionsController.swift
//  fanex
//
//  Created by aman shah on 01/03/23.
//

import Foundation
import  UIKit
import PopupDialog
class ActionsController : UIViewController {
  
    
  var imageArr = ["card1" ,"card2" ,"twitterAction", "card3"]
    @IBOutlet weak var caroselCollection: UICollectionView!
    
  
    @IBOutlet weak var carouselViewContainer: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        caroselCollection.register(UINib(nibName: "CarouselCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CarouselCollectionViewCell")
        
        caroselCollection.delegate = self
        caroselCollection.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
       
      }
    
    func createCarouselView () {
       
    }
}
extension  ActionsController : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let  cell = caroselCollection.dequeueReusableCell(withReuseIdentifier: "CarouselCollectionViewCell", for: indexPath) as? CarouselCollectionViewCell else {
            return CarouselCollectionViewCell()
        }
        cell.image.image = UIImage(named: imageArr[indexPath.row])
        cell.image.layer.cornerRadius = 50
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            // click on 1st card
            let vc = ScanQrController()
               self.present(vc, animated: true, completion: nil)
        }else if(indexPath.row == 1) {
            // click on 2nd card
            let vc = ScanQrController()
               self.present(vc, animated: true, completion: nil)
        }else  if(indexPath.row == 2) {
            let vc = TweetViewController()
            vc.twitterVCDelegate = self
               self.present(vc, animated: true, completion: nil)
        }
        else {
            debugPrint("print something")
        }
    }
    
    }
extension ActionsController : TweetControllerDismiss {
    func dismiss() {
               let title = "\(50) Fanex points Recieved"
               let message = "Keep an eye on upcoming tweets for more rewards"
               let image = UIImage(named: "congratulationsImage")

               // Create the dialog
               let popup = PopupDialog(title: title, message: message, image: image)

               // Create buttons
               let buttonOne = CancelButton(title: "Hell Yeahh!!") {
                   print("Hell Yeahh!!")
                   
               }

               // This button will not the dismiss the dialog
       //            let buttonTwo = DefaultButton(title: "ADMIRE CAR", dismissOnTap: false) {
       //                print("What a beauty!")
       //            }
       //
       //            let buttonThree = DefaultButton(title: "BUY CAR", height: 60) {
       //                print("Ah, maybe next time :)")
       //            }

               // Add buttons to dialog
               // Alternatively, you can use popup.addButton(buttonOne)
               // to add a single button
               popup.addButtons([buttonOne])

               // Present dialog
               self.present(popup, animated: true, completion: nil)
    }
}
    
    

