//
//  WalletConnectViewController.swift
//  Runner
//
//  Created by Abhimanyu Shekhawat on 02/03/21.
//

import UIKit

class WalletConnectViewController: UIViewController {
    @IBOutlet var addressLabel: UILabel!
    var address:String = ""
    var uri:String = ""
    var chainId:String = ""
    var privateKey:String = ""

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = address
        NSLog("Start remove sibview")
            if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
            }else{
                NSLog("No!")
            }
            // Do any additional setup after loading the view.
    }
    @IBAction func disconnectAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let homeC = storyBoard.instantiateViewController(withIdentifier: "main") as? FlutterViewController
  
        self.navigationController?.pushViewController(homeC!, animated: true)
        NSLog("asdads")
        
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
