import Foundation

public class AdLayoutFactory : NSObject, FlutterPlatformViewFactory {
    let messeneger: FlutterBinaryMessenger
    
    public init(messeneger: FlutterBinaryMessenger) {
        self.messeneger = messeneger
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AdLayout(
            frame: frame,
            viewId: viewId,
            args: args as? [String : Any] ?? [:],
            messeneger: messeneger
        )
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
