import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let walletconnect = FlutterMethodChannel(name: "com.pollywallet/walletconnect",
                                                  binaryMessenger: controller.binaryMessenger)
    walletconnect.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          // Note: this method is invoked on the UI thread.
          // Handle battery messages.
        let arguments = call.arguments as! Array<String>
        guard call.method == "launch" else {
            
           result(FlutterMethodNotImplemented)
           return
         }
        self.launchWalletConnect(result: result, address: arguments[0] as String, privateKey:  arguments[1] as String, uri: arguments[2] as String)
        })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    private func launchWalletConnect(result: FlutterResult, address: String, privateKey: String, uri: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let homeC = storyboard.instantiateViewController(withIdentifier: "walletconnect") as? WalletConnectViewController
        homeC?.address = address
        homeC?.privateKey = privateKey
        homeC?.uri = uri
            if homeC != nil {
                homeC!.view.frame = (self.window!.frame)
                self.window!.addSubview(homeC!.view)
                self.window!.bringSubviewToFront( homeC!.view)
            }
  
    }
    
}
