//
//  WalletConnectUtils.swift
//  Runner
//
//  Created by Abhimanyu Shekhawat on 04/03/21.
//
import Web3
import WalletConnectSwift

class BaseHandler: RequestHandler {

    weak var server: Server!
    weak var privateKey: EthereumPrivateKey!
    var chainId: Int!
    var uri: String!
    init( server: Server, privateKey: EthereumPrivateKey, uri: String, chainId: Int) {
        self.server = server
        self.privateKey = privateKey
        self.uri = uri
        self.chainId = chainId
    }

    func canHandle(request: Request) -> Bool {
        return false
    }

    func handle(request: Request) {
        // to override
    }

    func askToSign(request: Request, message: String, sign: @escaping () -> String) {
        let onSign = {
            let signature = sign()
            self.server.send(.signature(signature, for: request))
        }
        let onCancel = {
            self.server.send(.reject(request))
        }
        DispatchQueue.main.async {
            UIAlertController.showShouldSign(
                                             title: "Request to sign a message",
                                             message: message,
                                             onSign: onSign,
                                             onCancel: onCancel)
        }
    }
}

class PersonalSignHandler: BaseHandler {
    override func canHandle(request: Request) -> Bool {
        return request.method == "personal_sign"
    }

    override func handle(request: Request) {
        do {
            let messageBytes = try request.parameter(of: String.self, at: 0)
            let address = try request.parameter(of: String.self, at: 1)

            guard address == privateKey.address.hex(eip55: true) else {
                server.send(.reject(request))
                return
            }

            let decodedMessage = String(data: Data(hex: messageBytes), encoding: .utf8) ?? messageBytes

            askToSign(request: request, message: decodedMessage) {
                let personalMessageData = self.personalMessageData(messageData: Data(hex: messageBytes))
                let (v, r, s) = try! self.privateKey.sign(message: .init(hex: personalMessageData.toHexString()))
                return "0x" + r.toHexString() + s.toHexString() + String(v + 27, radix: 16) // v in [0, 1]
            }
        } catch {
            server.send(.invalid(request))
            return
        }
    }

    private func personalMessageData(messageData: Data) -> Data {
        let prefix = "\u{19}Ethereum Signed Message:\n"
        let prefixData = (prefix + String(messageData.count)).data(using: .ascii)!
        return prefixData + messageData
    }
}

class SignTransactionHandler: BaseHandler {
    override func canHandle(request: Request) -> Bool {
        return request.method == "eth_signTransaction"
    }

    override func handle(request: Request) {
        do {
            let transaction = try request.parameter(of: EthereumTransaction.self, at: 0)
            guard transaction.from == privateKey.address else {
                self.server.send(.reject(request))
                return
            }

            askToSign(request: request, message: transaction.description) {
                let signedTx = try! transaction.sign(with: self.privateKey, chainId: EthereumQuantity(ethereumValue: self.chainId))
                let (r, s, v) = (signedTx.r, signedTx.s, signedTx.v)
                
                return r.hex() + s.hex().dropFirst(2) + String(v.quantity, radix: 16)
            }
        } catch {
            self.server.send(.invalid(request))
        }
    }
}
class SendTransactionHandler: BaseHandler {
    override func canHandle(request: Request) -> Bool {
        return request.method == "eth_sendTransaction"
    }

    override func handle(request: Request) {
        do {
            let transaction = try request.parameter(of: EthereumTransaction.self, at: 0)
            guard transaction.from == privateKey.address else {
                self.server.send(.reject(request))
                return
            }

            askToSign(request: request, message: transaction.description) {
                let signedTx = try! transaction.sign(with: self.privateKey, chainId: EthereumQuantity(ethereumValue: self.chainId))
                let (r, s, v) = (signedTx.r, signedTx.s, signedTx.v)
                //send raw transaction
                return r.hex() + s.hex().dropFirst(2) + String(v.quantity, radix: 16)
            }
        } catch {
            self.server.send(.invalid(request))
        }
    }
}

extension Response {
    static func signature(_ signature: String, for request: Request) -> Response {
        return try! Response(url: request.url, value: signature, id: request.id!)
    }
}

extension FLNativeView: ServerDelegate {
    
    func server(_ server: Server, didFailToConnect url: WCURL) {
        onMainThread {
            UIAlertController.showFailedToConnect()
        }
    }

    func server(_ server: Server, shouldStart session: Session, completion: @escaping (Session.WalletInfo) -> Void) {
        let walletMeta = Session.ClientMeta(name: "PollyWallet",
                                            description: nil,
                                            icons: [],
                                            url: URL(string: "matic.network")!)
        let walletInfo = Session.WalletInfo(approved: true,
                                            accounts: [privateKey.address.hex(eip55: true)],
                                            chainId: 4,
                                            peerId: UUID().uuidString,
                                            peerMeta: walletMeta)
        onMainThread {
            UIAlertController.showShouldStart(clientName: session.dAppInfo.peerMeta.name, onStart: {
                completion(walletInfo)
            }, onClose: {
                completion(Session.WalletInfo(approved: false, accounts: [], chainId: 4, peerId: "", peerMeta: walletMeta))
               
            })
        }
    }
    //Int(self._args[3]) ?? 80001
    func server(_ server: Server, didConnect session: Session) {
        self.session = session
        let sessionData = try! JSONEncoder().encode(session)
        UserDefaults.standard.set(sessionData, forKey: sessionKey)
        onMainThread {
            self.dappLabel.text = "Connected to \(session.dAppInfo.peerMeta.name)"
        }
    }

    func server(_ server: Server, didDisconnect session: Session) {
        UserDefaults.standard.removeObject(forKey: sessionKey)
        onMainThread {
           
            self.statusLabelText = "Disconnected"
        }
    }
}


extension UIAlertController {
    func withCloseButton(title: String = "Close", onClose: (() -> Void)? = nil ) -> UIAlertController {
        addAction(UIAlertAction(title: title, style: .cancel) { _ in onClose?() } )
        return self
    }

    static func showShouldStart( clientName: String, onStart: @escaping () -> Void, onClose: @escaping (() -> Void)) {
        let alert = UIAlertController(title: "Request to start a session", message: clientName, preferredStyle: .alert)
        let startAction = UIAlertAction(title: "Start", style: .default) { _ in onStart() }
        alert.addAction(startAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert.withCloseButton(onClose: onClose), animated: true)
    }

    static func showFailedToConnect() {
        let alert = UIAlertController(title: "Failed to connect", message: nil, preferredStyle: .alert)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert.withCloseButton(), animated: true)
    }

    static func showDisconnected() {
        let alert = UIAlertController(title: "Did disconnect", message: nil, preferredStyle: .alert)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert.withCloseButton(), animated: true)
    }

    static func showShouldSign(title: String, message: String, onSign: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let startAction = UIAlertAction(title: "Sign", style: .default) { _ in onSign() }
        alert.addAction(startAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert.withCloseButton(title: "Reject", onClose: onCancel), animated: true)
    }
}

extension EthereumTransaction {
    var description: String {
        return """
        to: \(String(describing: to!.hex(eip55: true))),
        value: \(String(describing: value!.hex())),
        gasPrice: \(String(describing: gasPrice!.hex())),
        gas: \(String(describing: gas!.hex())),
        data: \(data.hex()),
        nonce: \(String(describing: nonce!.hex()))
        """
    }
}
