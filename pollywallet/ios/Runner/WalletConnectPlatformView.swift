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
    deinit {
        do{
        try self.server.disconnect(from: self.session)
            statusLabel.text = "Disconnected"
            disconnectButton.setTitle("Connect", for: UIControl.State.normal)
        }
        catch {
            NSLog("Failed")
        }
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
    
}
