import Flutter
import UIKit
import GoogleMobileAds

public class NativeAds: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_ads", binaryMessenger: registrar.messenger())
    let instance = NativeAds()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(
        AdLayoutFactory(messeneger: registrar.messenger()),
        withId: "native_ads/ad_layout"
    )
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        result(true)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
