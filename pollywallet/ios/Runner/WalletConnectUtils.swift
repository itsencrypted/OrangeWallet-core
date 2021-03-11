//
//  WalletConnectUtils.swift
//  Runner
//
//  Created by Abhimanyu Shekhawat on 04/03/21.
//
import Web3
import WalletConnectSwift
import Web3PromiseKit
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
                                             onCancel: onCancel
            )
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
                var signedTx:EthereumSignedTransaction
                if(self.chainId == 80001){
                    signedTx = try! transaction.sign(with: self.privateKey, chainId: 80001)

                }else if(self.chainId == 80001) {
                    signedTx = try! transaction.sign(with: self.privateKey, chainId: 137)

                }else {
                    signedTx = try! transaction.sign(with: self.privateKey, chainId: 80001)

                    NSLog("Invalid chainId")
                }
                var rpcEndpoint:String
                if(self.chainId == 137){
                    rpcEndpoint = "https://rpc-mainnet.matic.network"
                }else{
                    rpcEndpoint = "https://rpc-mumbai.matic.today"
                }
                let web3 = Web3(rpcURL: rpcEndpoint)
                let data = web3.eth.sendRawTransaction(transaction: signedTx)
                NSLog(data.result.debugDescription)
                return try! data.wait().hex()
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
                                            chainId: Int(self._args[3]) ?? 80001,
                                            peerId: UUID().uuidString,
                                            peerMeta: walletMeta)
        onMainThread {
            UIAlertController.showShouldStart(clientName: session.dAppInfo.peerMeta.name, onStart: {
                completion(walletInfo)
            }, onClose: {
                completion(Session.WalletInfo(approved: false, accounts: [], chainId: Int(self._args[3]) ?? 80001, peerId: "", peerMeta: walletMeta))
               
            })
        }
    }
    //Int(self._args[3]) ?? 80001
    func server(_ server: Server, didConnect session: Session) {
        self.session = session
        let sessionData = try! JSONEncoder().encode(session)
        UserDefaults.standard.set(sessionData, forKey: sessionKey)
        onMainThread {
            self.dappLabel.text = session.dAppInfo.peerMeta.url.description
            self.statusLabel.text = "Connected"
        }
    }

    func server(_ server: Server, didDisconnect session: Session) {
        UserDefaults.standard.removeObject(forKey: sessionKey)
        onMainThread {
           
            self.statusLabelText = "Disconnected"
        }
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

