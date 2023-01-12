//
//  ARTrackingViewController.swift
//  flutter_ar_image_tracking_f2n
//
//  Created by Junseo Youn on 2022/10/17.
//

import Foundation
import ARKit
import Kingfisher
import CoreImage
import Alamofire

/**
 ARTrackingViewController
 
 */
class ARTrackingViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    var trackerImagePath: String?
    var trackerImageWidth: CGFloat = 0.1
    var overlayImagePath: String?
    
    private var statusbarOverlay: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: effect)
    }()
    // AR 화면
    private lazy var sceneView = ARSCNView()
    // 하단 버튼 (취소, 액션)
    private lazy var buttonStack = UIStackView()
    private lazy var closeButton = SolidButton()
    private lazy var actionButton = SolidButton()
    // 추적 이미지
    private var targetImage: UIImage?
    private var targetImageWidth: CGFloat?
    // 결과 GIF 이미지 여부
    private var isGifImage: Bool = false
    // 결과 이미지
    private var overlayImage: UIImage?
    // 결과 GIF 이미지
    private var overlayGifAnimation: CAKeyframeAnimation?
    
    private var isFailOriginalTargetImageURL = false
    private var isFailOriginalOveralyImageURL = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // 이미지 다운로드
        trackerImageDownLoad(urlStr: trackerImagePath!)
        overlayImageDownload(urlStr: overlayImagePath!)
        targetImageWidth = trackerImageWidth
        
        if !ARConfiguration.isSupported {
            /// TODO AR지원안됨처리
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stARScreen()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sceneView.session.pause()
    }
    // MARK: - View Setup
    
    private func setup() {
        view.backgroundColor = .appBackgroundMain
        
        sceneView.delegate = self
        view.addSubview(sceneView)
        sceneView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(statusbarOverlay)
        statusbarOverlay.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fill
        buttonStack.alignment = .fill
        buttonStack.spacing = 8
        
        [closeButton, actionButton].forEach { [weak self] in
            $0.setTitleColor(.black, for: .normal)
            $0.buttonColor = .white
            $0.titleLabel?.textAlignment = .center
            self?.buttonStack.addArrangedSubview($0)
        }
        
        actionButton.isEnabled = false
        
        closeButton.setTitle("취소", for: .normal)
        closeButton.addTarget(self, action: #selector(tapped(close:)), for: .touchUpInside)
        
        actionButton.setTitle("액션", for: .normal)
        actionButton.addTarget(self, action: #selector(tapped(action:)), for: .touchUpInside)
        
        view.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { (make) in
            make.leading.equalTo(view.readableContentGuide.snp.leading)
            make.trailing.equalTo(view.readableContentGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            make.height.equalTo(46)
        }
        closeButton.snp.makeConstraints { (make) in
            make.width.equalTo(actionButton).multipliedBy(0.3)
        }
    }

    
    // MARK: - 게임 로직 처리
    private func stARScreen() {
        let configuration = ARWorldTrackingConfiguration()
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        if let image = targetImage, let cgImage = image.cgImage, let targetImageWidth = targetImageWidth {
            let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: targetImageWidth)
            
            configuration.detectionImages = [referenceImage]
        }
        sceneView.session.run(configuration, options: options)
    }
    
    private func reARScreen() {
        sceneView.session.pause()
        stARScreen()
    }
    
    @objc private func tapped(close button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func tapped(action button: UIButton) {
        // guard let actionId = quest?.action?.id else { return }
        actionButton.isEnabled = false
//        dismiss(animated: true) {
//            self.actionButton.isEnabled = true
//            let missionViewController = UIApplication.shared.keyWindow?.topViewController() as? MissionViewController
//            missionViewController?.run(actionId: actionId) { (results, error) in
//                guard let results = results else { return }
//                missionViewController?.handle(actionResults: results, project: self.project, with: self.themeColor)
//            }
//        }
    }
    // MARK: - 이미지 처리 유틸
    private func trackerImageDownLoad(urlStr: String) {
        var targetImageUrlString = urlStr
        if (isFailOriginalTargetImageURL) {
            targetImageUrlString = targetImageUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        guard let targetImageUrl = URL(string: targetImageUrlString) else {
            return
        }
        ImageDownloader.default.downloadImage(with: targetImageUrl) { [weak self] result in
            switch result {
            case .success(let value):
                let maxColor = self?.areaMaxColor(image: value.image)
                let image = self?.transperent(image: value.image, toColor: maxColor!)
                self?.targetImage = image
                self?.reARScreen()
            case .failure(_):
                guard !self!.isFailOriginalTargetImageURL else {
                    return
                }
                self!.isFailOriginalTargetImageURL = true
                self?.trackerImageDownLoad(urlStr: urlStr)
            }
        }
    }
    private func overlayImageDownload(urlStr: String) {
        var overlayImageUrlString = urlStr
        if (isFailOriginalOveralyImageURL) {
            overlayImageUrlString = overlayImageUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        guard let overlayImageUrl = URL(string: overlayImageUrlString) else {
            return
        }
        if overlayImageUrl.pathExtension.lowercased() == "gif" {
            isGifImage = true
            AF.request(overlayImageUrl).responseData { [weak self] (response) in
                if let data = response.value, let gifImage = self?.createGIFAnimation(data: data) {
                    self?.overlayGifAnimation = gifImage
                    self?.reARScreen()
                } else {
                 guard  !(self?.isFailOriginalOveralyImageURL ?? false) else {
//                        UIAlertController.showConfirmAlert(title: Localizations.Label.Error, message: Localizations.Label.ARImageNotFound)
                     return
                 }
                 self?.isFailOriginalOveralyImageURL = true
                 self?.overlayImageDownload(urlStr: urlStr)
                }
            }
        } else {
            ImageDownloader.default.downloadImage(with: overlayImageUrl) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.overlayImage = value.image
                    self?.reARScreen()
                case .failure(_):
                    guard  !self!.isFailOriginalOveralyImageURL else {
//                        UIAlertController.showConfirmAlert(title: Localizations.Label.Error, message: Localizations.Label.ARImageNotFound)
                        return
                    }
                    self!.isFailOriginalOveralyImageURL = true
                    self!.overlayImageDownload(urlStr: urlStr)
                }
            }
        }
    }
    /// 이미지에서 가장 많이 포함된 색을 리턴해줌
    ///
    /// - Parameter image: 타겟 이미지
    /// - Returns: 가장 많이 사용된 색
    func areaMaxColor(image: UIImage) -> UIColor {
        let tmpImage = image
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        let inputImage = CIImage(cgImage: tmpImage.cgImage!)
        let extent = inputImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let filter = CIFilter(name: "CIAreaMaximum", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])
        let outputImage = filter!.outputImage!
        let outputExtent = outputImage.extent
        assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        return UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
    }
    /// 투명으로 된 부분을 하얀색으로 바꿔주는 메소드
    ///
    /// - Parameters:
    ///   - image: 바꾸길 원하는 이미지
    ///   - color: 채워 넣길 원하는 색
    /// - Returns: 색이 적용된 이미지
    func transperent(image: UIImage, toColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let imageRect: CGRect = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        var colorNumbers = color.cgColor.components!
        if colorNumbers[3] < 0.9 {
            colorNumbers[3] = 1.0
        }
        context.setFillColor(red: colorNumbers[0], green: colorNumbers[1], blue: colorNumbers[2], alpha: colorNumbers[3])
        context.fill(imageRect)
        image.draw(in: imageRect, blendMode: .normal, alpha: 1.0)
        let mask: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return mask
    }
    private func createGIFAnimation(data: Data) -> CAKeyframeAnimation? {
        print(Date())
        guard let provider = CGDataProvider(data: data as CFData), let src = CGImageSourceCreateWithDataProvider(provider, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(src)

        // Total loop time
        var time : Float = 0

        // Arrays
        var framesArray = [AnyObject]()
        var tempTimesArray = [NSNumber]()

        // Loop
        for i in 0..<frameCount {

            // Frame default duration
            var frameDuration : Float = 0.1;

            let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, i, nil)
            guard let framePrpoerties = cfFrameProperties as? [String:AnyObject] else {return nil}
            guard let gifProperties = framePrpoerties[kCGImagePropertyGIFDictionary as String] as? [String:AnyObject]
                else { return nil }

            // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
            if let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
                frameDuration = delayTimeUnclampedProp.floatValue
            } else {
                if let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                    frameDuration = delayTimeProp.floatValue
                }
            }

            // Make sure its not too small
            if frameDuration < 0.011 {
                frameDuration = 0.100;
            }

            // Add frame to array of frames
            if let frame = CGImageSourceCreateImageAtIndex(src, i, nil) {
                tempTimesArray.append(NSNumber(value: frameDuration))
                framesArray.append(frame)
            }

            // Compile total loop time
            time = time + frameDuration
        }

        var timesArray = [NSNumber]()
        var base : Float = 0
        for duration in tempTimesArray {
            timesArray.append(NSNumber(value: base))
            base += ( duration.floatValue / time )
        }

        // From documentation of 'CAKeyframeAnimation':
        // the first value in the array must be 0.0 and the last value must be 1.0.
        // The array should have one more entry than appears in the values array.
        // For example, if there are two values, there should be three key times.
        timesArray.append(NSNumber(value: 1.0))

        // Create animation
        let animation = CAKeyframeAnimation(keyPath: "contents")

//        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.duration = CFTimeInterval(time)
        animation.repeatCount = Float.greatestFiniteMagnitude;
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.values = framesArray
        animation.keyTimes = timesArray
        animation.calculationMode = CAAnimationCalculationMode.discrete
        print(Date())
        return animation;
    }
}
// MARK: - AR
extension ARTrackingViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        DispatchQueue.main.async { [weak self] in
//            print(Date())
            guard let isGifImage = self?.isGifImage, let targetImageSize = self?.targetImage?.size else { return }
            let referenceImage = imageAnchor.referenceImage
            let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
            
            if isGifImage == true {
                guard let overlayGifAnimation = self?.overlayGifAnimation else { return }
                let layer = CALayer()
                layer.frame = CGRect(x: 0, y: 0, width: targetImageSize.width, height: targetImageSize.height)
                layer.add(overlayGifAnimation, forKey: "contents")
                
                let newMaterial = SCNMaterial()
                newMaterial.isDoubleSided = true
                newMaterial.diffuse.contents = layer
                plane.materials = [newMaterial]
            } else {
                guard let overlayImage = self?.overlayImage else { return }
                plane.firstMaterial?.diffuse.contents = overlayImage
            }
            
            // Logger.ARtimer(time: String(self?.timerCount ?? 0), questID: String(self?.quest?.id ?? -999))
            // self?.timer?.invalidate()
            
            self?.actionButton.isEnabled = true
            self?.actionButton.buttonColor = .primaryPurple100
            self?.actionButton.setTitleColor(.white, for: .normal)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 1
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            // self?.guideImageView.isHidden = true
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print(anchor)
    }
}

