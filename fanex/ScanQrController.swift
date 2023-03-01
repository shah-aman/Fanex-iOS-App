//
//  ScanQrController.swift
//  fanex
//
//  Created by aman shah on 27/02/23.
//

import UIKit
import MercariQRScanner
import AVFoundation
import PopupDialog
class ScanQrController: UIViewController {
  
    var popUpView : UIView? 

    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanner()
        // Do any additional setup after loading the view.
    }
    
    private func setupQRScanner() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                setupQRScannerView()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    if granted {
                        DispatchQueue.main.async { [weak self] in
                            self?.setupQRScannerView()
                        }
                    }
                }
            default:
                showAlert()
            }
        }
    
    private func setupQRScannerView() {
          let qrScannerView = QRScannerView(frame: view.bounds)
          view.addSubview(qrScannerView)
          qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
          qrScannerView.startRunning()
      }

      private func showAlert() {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
              let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
              alert.addAction(.init(title: "OK", style: .default))
              self?.present(alert, animated: true)
          }
      }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ScanQrController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: MercariQRScanner.QRScannerView, didFailure error: MercariQRScanner.QRScannerError) {
        print(error)
    }
    
    func qrScannerView(_ qrScannerView: MercariQRScanner.QRScannerView, didSuccess code: String) {
        print(code)
       var qrCodesManager =  ValidQrCodes()
        if ((qrCodesManager.codes[code]) != nil){
            debugPrint("its a valide code")
//            let APIManager = ServiceManager.shared
          

            // Prepare the popup assets
            let title = "\(qrCodesManager.codes[code]) Fanex points Recieved"
            let message = "Keep completing tasks to earn more rewards"
            let image = UIImage(named: "congratulationsImage")
        
            // Create the dialog
            let popup = PopupDialog(title: title, message: message, image: image)

            // Create buttons
            let buttonOne = CancelButton(title: "CANCEL") {
                print("Hell Yeahh!!")
            }
            TokenAmount.shared.totalToken += qrCodesManager.codes[code] ?? 0
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
            
            
        }else {
            debugPrint("Fuck you dont cheat we are seeing you")
        }
    }
    
    func qrScannerView(_ qrScannerView: MercariQRScanner.QRScannerView, didChangeTorchActive isOn: Bool) {
        debugPrint("do nothing")
    }
}
