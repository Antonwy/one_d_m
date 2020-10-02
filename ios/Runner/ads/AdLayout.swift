import Foundation
import GoogleMobileAds

class AdLayout : NSObject, FlutterPlatformView {
    
    private let channel: FlutterMethodChannel
    private let messeneger: FlutterBinaryMessenger
    private let frame: CGRect
    private let viewId: Int64
    private let args: [String: Any]
    private let adLoader: GADAdLoader
    
    private let adUnitId: String
    private let layoutName: String
    
    private let containerView: UIView!
    private let unifiedNativeAdView: GADUnifiedNativeAdView!
    
    private weak var headlineView: UILabel!
    private weak var bodyView: UILabel!
    private weak var callToActionView: UILabel!

    private weak var mediaView: GADMediaView?
    private weak var iconView: UIImageView?
    private weak var starRatingView: UILabel?
    private weak var storeView: UILabel?
    private weak var priceView: UILabel?
    private weak var advertiserView: UILabel?
    
    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger) {
        self.args = args
        self.messeneger = messeneger
        self.frame = frame
        self.viewId = viewId
        self.adUnitId = self.args["ad_unit_id"] as! String
        self.layoutName = self.args["layout_name"] as! String

        let mediaOptions = GADNativeAdMediaAdLoaderOptions();
        mediaOptions.mediaAspectRatio = GADMediaAspectRatio.landscape
        self.adLoader = GADAdLoader(adUnitID: adUnitId, rootViewController: nil,
                            adTypes: [ .unifiedNative ], options: [mediaOptions])
        channel = FlutterMethodChannel(name: "native_ads/ad_layout_\(viewId)", binaryMessenger: messeneger)
        
        guard let nibObjects = Bundle.main.loadNibNamed(layoutName, owner: nil, options: nil),
              let adView = nibObjects.first as? GADUnifiedNativeAdView else {
            fatalError("Could not load nib file for adView")
        }
        unifiedNativeAdView = adView
        containerView = NotifyingContainerView(frame: frame, channel: channel)
        containerView.addSubview(unifiedNativeAdView)
        
        unifiedNativeAdView.translatesAutoresizingMaskIntoConstraints = false
        unifiedNativeAdView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        unifiedNativeAdView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        unifiedNativeAdView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true

        super.init()
        mappingView()
        fetchAd()
    }

    private func mappingView() {
        headlineView = unifiedNativeAdView.headlineView as? UILabel
        bodyView = unifiedNativeAdView.bodyView as? UILabel
        callToActionView = unifiedNativeAdView.callToActionView as? UILabel
        mediaView = unifiedNativeAdView.mediaView
        iconView = unifiedNativeAdView.iconView as? UIImageView
        starRatingView = unifiedNativeAdView.starRatingView as? UILabel
        storeView = unifiedNativeAdView.storeView as? UILabel
        priceView = unifiedNativeAdView.priceView as? UILabel
        advertiserView = unifiedNativeAdView.advertiserView as? UILabel
    }

    private func fetchAd() {
        adLoader.delegate = self
        let request = GADRequest()
        adLoader.load(request)
    }
    
    func view() -> UIView {
        return containerView
    }
    
    fileprivate func dispose() {
        unifiedNativeAdView.nativeAd = nil
        channel.setMethodCallHandler(nil)
    }
}

extension AdLayout : GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        channel.invokeMethod("onAdFailedToLoad", arguments: ["errorCode": error.code, "message": error.localizedDescription])
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        headlineView.text = nativeAd.headline
        bodyView.text = nativeAd.body
        callToActionView.text = nativeAd.callToAction
        unifiedNativeAdView.nativeAd = nativeAd

        mediaView?.mediaContent = nativeAd.mediaContent
        
        if((1 / nativeAd.mediaContent.aspectRatio).isFinite) {
            mediaView?.heightAnchor.constraint(equalTo: mediaView!.widthAnchor, multiplier: 1 / nativeAd.mediaContent.aspectRatio).isActive = true
        }
    
        iconView?.image = nativeAd.icon?.image
        starRatingView?.text = String(describing: nativeAd.starRating?.doubleValue)
        storeView?.text = nativeAd.store
        priceView?.text = nativeAd.price
        advertiserView?.text = nativeAd.advertiser
        
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
    }
}

// MARK: - GADUnifiedNativeAdDelegate implementation
extension AdLayout : GADUnifiedNativeAdDelegate {
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
        channel.invokeMethod("onAdClicked", arguments: nil)
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
        channel.invokeMethod("onAdImpression", arguments: nil)
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
        channel.invokeMethod("onAdLeftApplication", arguments: nil)
    }
}


class NotifyingContainerView : UIView {
    private var channel: FlutterMethodChannel?
    
    init(frame: CGRect, channel: FlutterMethodChannel) {
        self.channel = channel
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews();
        
        channel?.invokeMethod("onAdLoaded", arguments: self.subviews[0].bounds.height)
    }
}
