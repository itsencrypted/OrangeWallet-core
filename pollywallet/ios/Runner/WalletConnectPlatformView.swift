//
//  WalletConnectPlatformView.swift
//  Runner
//
//  Created by Abhimanyu Shekhawat on 03/03/21.
//

import Flutter
import UIKit
import Web3
import WalletConnectSwift


class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    var _args : Array<String>
    var server: Server!
    var session: Session!
    var dapp: String = ""
    let dappLabel = UILabel()
    let statusLabel = UILabel()
    let disconnectButton:UIButton = UIButton(frame: CGRect(x: 0 , y:0, width: 200, height: 50))

    let privateKey: EthereumPrivateKey

    let sessionKey = "sessionKey"
    var statusLabelText = "Disconnected"
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        privateKey = try! EthereumPrivateKey(
            privateKey: .init(hex: (args as! Array<String>)[1]))
       _args = args as! Array<String>
        super.init()
        createNativeView(view: _view)
        configureServer()
       
    }

    func view() -> UIView {
        return _view
    }
    func onMainThread(_ closure: @escaping () -> Void) {
           if Thread.isMainThread {
               closure()
           } else {
               DispatchQueue.main.async {
                   closure()
               }
           }
       }
    private func configureServer() {
       
        server = Server(delegate: self)
        guard let url = WCURL(_args[2]) else { return }
        server.register(handler: PersonalSignHandler(server: server, privateKey: privateKey, uri: _args[2], chainId: Int(_args[3]) ?? 80001))
            server.register(handler: SignTransactionHandler(server: server, privateKey: privateKey, uri: _args[2], chainId: Int(_args[3]) ?? 80001))

        do {
            try self.server.connect(to: url)
        } catch {
            return
        }
            if let oldSessionObject = UserDefaults.standard.object(forKey: sessionKey) as? Data,
                let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject) {
                try? server.reconnect(to: session)
            }
        }
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
        statusLabel.text = "Connected";
        statusLabel.textColor = UIColor.black
        statusLabel.textAlignment = .center
        statusLabel.frame = CGRect(x: 60, y: 0, width: 48 , height: 48.0)
        statusLabel.sizeToFit()
        _verticalStack.addArrangedSubview(statusLabel)
        
        //Disconnect button
        disconnectButton.backgroundColor = UIColor(red: 130/255, green: 72/255, blue: 229/255, alpha: 1)
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
            do{
            try self.server.disconnect(from: self.session)
                statusLabel.text = "Disconnected"
                disconnectButton.setTitle("Connect", for: UIControl.State.normal)
            }
            catch {
                NSLog("Failed")
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
