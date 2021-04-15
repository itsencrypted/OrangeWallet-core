//
//  UiScreenWalletConnect.swift
//  Runner
//
//  Created by Abhimanyu Shekhawat on 05/03/21.
//
import WalletConnectSwift
extension FLNativeView {
    func createNativeView(view _view: UIView){
        
        _view.backgroundColor = UIColor(red:243/255 , green:242/255, blue: 239/255, alpha: 0)
        let _verticalStack = UIStackView();
        _verticalStack.axis = NSLayoutConstraint.Axis.vertical
        _verticalStack.distribution = UIStackView.Distribution.equalSpacing
        _verticalStack.alignment = UIStackView.Alignment.top
        _verticalStack.spacing = 10;
        // Address Tag label
        let addressTag = UILabel()
        addressTag.text = "Address :"
        addressTag.font = UIFont.boldSystemFont(ofSize: 16.0)
        addressTag.textColor = UIColor.black
        addressTag.textAlignment = .center
        addressTag.frame = CGRect(x: 20, y: 0, width: 48 , height: 48.0)
        addressTag.sizeToFit()
        _verticalStack.addArrangedSubview(addressTag)
        // Address label
        let addressLabel = UILabel()
        addressLabel.text = _args[0];
        addressLabel.textColor = UIColor.black
        addressLabel.textAlignment = .center
        addressLabel.frame = CGRect(x: 60, y: 0, width: 48 , height: 48.0)
        addressLabel.sizeToFit()
        _verticalStack.addArrangedSubview(addressLabel)
        
        // DApp name
        let dappNameTag = UILabel()
        dappNameTag.text = "Dapp :"
        dappNameTag.font = UIFont.boldSystemFont(ofSize: 16.0)
        dappNameTag.textColor = UIColor.black
        dappNameTag.textAlignment = .center
        dappNameTag.frame = CGRect(x: 20, y: 0, width: 48 , height: 48.0)
        dappNameTag.sizeToFit()
        _verticalStack.addArrangedSubview(dappNameTag)
        // dapp label
        dappLabel.text = dapp;
        dappLabel.textColor = UIColor.black
        dappLabel.textAlignment = .center
        dappLabel.frame = CGRect(x: 60, y: 0, width: 48 , height: 48.0)
        dappLabel.sizeToFit()
        _verticalStack.addArrangedSubview(dappLabel)
        // Status tag
        let statusTag = UILabel()
        statusTag.text = "Status :"
        statusTag.font = UIFont.boldSystemFont(ofSize: 16.0)
        statusTag.textColor = UIColor.black
        statusTag.textAlignment = .center
        statusTag.frame = CGRect(x: 20, y: 0, width: 48 , height: 48.0)
        statusTag.sizeToFit()
        _verticalStack.addArrangedSubview(statusTag)
        // Status label
        statusLabel.textColor = UIColor.black
        statusLabel.textAlignment = .center
        statusLabel.frame = CGRect(x: 60, y: 0, width: 48 , height: 48.0)
        statusLabel.sizeToFit()
        _verticalStack.addArrangedSubview(statusLabel)
        
        //Network Name
        let networkTag = UILabel()
        networkTag.text = "Network :"
        networkTag.font = UIFont.boldSystemFont(ofSize: 16.0)
        networkTag.textColor = UIColor.black
        networkTag.textAlignment = .center
        networkTag.frame = CGRect(x: 20, y: 0, width: 48 , height: 48.0)
        networkTag.sizeToFit()
        _verticalStack.addArrangedSubview(networkTag)
        // Status label
        networkLabel.textColor = UIColor.black
        networkLabel.textAlignment = .center
        networkLabel.frame = CGRect(x: 60, y: 0, width: 48 , height: 48.0)
        networkLabel.sizeToFit()
        _verticalStack.addArrangedSubview(networkLabel)
        
        //Disconnect button
        disconnectButton.backgroundColor = UIColor(red: 235/255, green: 91/255, blue: 86/255, alpha: 1)
        disconnectButton.setTitle("Disconnect", for: UIControl.State.normal)
        disconnectButton.layer.cornerRadius = 10
        disconnectButton.titleEdgeInsets = UIEdgeInsets.init(top: 10, left: 10,bottom: 10,right: 10)
        disconnectButton.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        disconnectButton.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
        _verticalStack.addArrangedSubview(disconnectButton)
        disconnectButton.translatesAutoresizingMaskIntoConstraints = false
       // disconnectButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        disconnectButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        disconnectButton.centerXAnchor.constraint(equalTo: _verticalStack.centerXAnchor).isActive = true
        
        //stack config
        _verticalStack.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
        _verticalStack.isLayoutMarginsRelativeArrangement = true
        _view.addSubview(_verticalStack)
        _verticalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            _verticalStack.topAnchor.constraint(equalTo: _view.topAnchor),
            _verticalStack.leftAnchor.constraint(equalTo: _view.leftAnchor),
            _verticalStack.rightAnchor.constraint(equalTo: _view.rightAnchor),
            _verticalStack.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    @objc func buttonClicked(){
        if(statusLabel.text == "Connected"){
            if(self.session != nil){
                do{
                try self.server.disconnect(from: self.session)
                    statusLabel.text = "Disconnected"
                    disconnectButton.setTitle("Connect", for: UIControl.State.normal)
                }
                catch {
                    NSLog("Failed")
                }
            }else {
                statusLabel.text = "Disconnected"
                disconnectButton.setTitle("Connect", for: UIControl.State.normal)
            }

        }else {
            do{
                guard let url = WCURL(_args[2]) else { return }
                try self.server.connect(to:url)
                statusLabel.text = "Connected"
                disconnectButton.setTitle("Disconnect", for: UIControl.State.normal)

            }catch {}
        }
        
    }
  
    
}
