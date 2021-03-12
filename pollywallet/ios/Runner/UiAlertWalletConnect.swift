//
//  UiAlertWalletConnect.swift
//  Runner
//
//  Created by Abhimanyu Shekhawat on 05/03/21.
//

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
        UIApplication.shared.keyWindow?.rootViewController?.present(alert.withCloseButton(
                                                                        title: "Reject", onClose: onCancel
        ), animated: true
                                                                    
        )
    }
}
