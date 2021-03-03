//
//  WalletConnectViewController.swift
//  Runner
//
//  Created by Abhimanyu Shekhawat on 02/03/21.
//

import UIKit

class WalletConnectViewController: UIViewController {
    @IBOutlet weak var addressLabel: UILabel!
    var address:String = ""
    var uri:String = ""
    var chainId:String = ""
    var privateKey:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = address
        // Do any additional setup after loading the view.
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
