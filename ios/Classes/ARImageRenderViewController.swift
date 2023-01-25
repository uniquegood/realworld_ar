//
//  ARImageRenderViewController.swift
//  realworld_ar
//
//  Created by Channoori Park on 2023/01/20.
//

import Foundation
import ARKit
import CoreImage
import SnapKit
import Alamofire
import Kingfisher



class QuestARImageRecognitionViewController: UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private var statusbarOverlay: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: effect)
    }()
    private lazy var sceneView = ARSCNView()
    private lazy var helpLabelContainerView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: effect)
    }()
    private lazy var helpLabel = UILabel()
    private lazy var buttonStack = UIStackView()
    private lazy var closeButton = SolidButton()
    private lazy var actionButton = SolidButton()
    private lazy var onboardingView = UIView(frame: .zero)
    
    private var targetImage: UIImage?
    private var overlayImage: UIImage?
    private var guideImageView: UIImageView = UIImageView(frame: .zero)
    private var targetImageWidth: CGFloat?
    private var isGifImage: Bool = false
    private var overlayGifAnimation: CAKeyframeAnimation?
    private var isFailOriginalTargetImageURL = false
    private var isFailOriginalOveralyImageURL = false
    private var timerCount = 0
    private var timer: Timer?
    
    var completeHandler: (Bool) -> Void
    var buttonLabel: String?
    var guideImageString: String?
    var augmentedImageString: String
    var augmentedImageWidth: Double?
    var overlayImageString: String
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(buttonLabel: String?, guideImageString: String?, augmentedImageString: String, augmentedImageWidth: Double?, overlayImageString: String, completeHandler: @escaping ((Bool) -> Void)) {
        self.buttonLabel = buttonLabel
        self.guideImageString = guideImageString
        self.augmentedImageString = augmentedImageString
        self.augmentedImageWidth = augmentedImageWidth
        self.overlayImageString = overlayImageString
        self.completeHandler = completeHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        debug_update()
        if !ARConfiguration.isSupported {
            //TODO - result 보내기
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timerCount = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startTracking()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        sceneView.session.pause()
    }
    
    // MARK: - SubView
    func setOnboardingView() -> UIView {
        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = .white
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { (view) in
            view.edges.equalToSuperview()
        }
        
        let onboardingImageView = UIImageView(frame: .zero)
        onboardingImageView.image = UIImage(named: "AR_Guide_Image")
        containerView.addSubview(onboardingImageView)
        onboardingImageView.snp.makeConstraints { (view) in
            view.width.equalToSuperview().inset(38)
            view.height.equalTo(onboardingImageView.snp.width)
            view.centerX.equalToSuperview()
            view.centerY.equalTo(containerView.snp.centerY).offset(24)
        }
        
        let subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.numberOfLines = 0
        subTitleLabel.text = "너무 어둡거나 그림자가 심하면 인식이 어려워요"
        subTitleLabel.textAlignment = .center
        //MARK: - 폰트설정
//        subTitleLabel.font = .body
        subTitleLabel.textColor = UIColor.init(rgb: 0x626262)
        subTitleLabel.sizeToFit()
        containerView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { (view) in
            view.bottom.equalTo(onboardingImageView.snp.top).offset(-28)
            view.centerX.equalToSuperview()
            view.left.right.equalToSuperview()
        }
        
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = "인식하려는 부분을\n정확하게 비추고 기다려주세요"
//        titleLabel.font = .displayMedium
        titleLabel.textColor = UIColor.init(rgb: 0x282F89)
        titleLabel.sizeToFit()
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.bottom.equalTo(subTitleLabel.snp.top).offset(-20)
        }
        
        
        let doneButton = SolidButton()
        doneButton.buttonColor = UIColor(rgb: 0xC869FF)
        doneButton.titleColor = .white
//        doneButton.setFont(UIFont.notoFont(type: .medium, size: 16))
        doneButton.titleLabel?.textAlignment = .center
        doneButton.setTitle("확인", for: .normal)
        doneButton.addTarget(self, action: #selector(clickOKOnboardingView(_:)), for: .touchUpInside)
        containerView.addSubview(doneButton)
        
        doneButton.snp.makeConstraints { (view) in
            view.height.equalTo(48)
            view.right.left.equalToSuperview().inset(16)
            view.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        
        return containerView
    }
    
    // MARK: - Action
    private func targetImageDownLoad(urlStr: String) {
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
                self?.restartTracking()
            case .failure(_):
                guard !self!.isFailOriginalTargetImageURL else {
//                    UIAlertController.showConfirmAlert(title: "오류", message: "AR 리소스를 다운받을 수 없습니다.")
                    return
                }
                self!.isFailOriginalTargetImageURL = true
                self?.targetImageDownLoad(urlStr: urlStr)
            }
        }
    }
    private func overalyImageDownload(urlStr: String) {
        var overlayImageUrlString = urlStr
        if (isFailOriginalOveralyImageURL) {
            overlayImageUrlString = overlayImageUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        guard let overlayImageUrl = URL(string: overlayImageUrlString) else {
            return
        }
        if overlayImageUrl.pathExtension.lowercased() == "gif" {
            isGifImage = true
            AF.request(overlayImageUrl).response { [weak self] (response) in
                
                if let datatemp = response.value, let data = datatemp, let gifImage = self?.createGIFAnimation(data: data) {
                    self?.overlayGifAnimation = gifImage
                    self?.restartTracking()
                } else {
                 guard  !(self?.isFailOriginalOveralyImageURL ?? false) else {
//                        UIAlertController.showConfirmAlert(title: "오류", message: "AR 리소스를 다운받을 수 없습니다.")
                     return
                 }
                 self?.isFailOriginalOveralyImageURL = true
                 self?.overalyImageDownload(urlStr: urlStr)
                }
            }
        } else {
            ImageDownloader.default.downloadImage(with: overlayImageUrl) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.overlayImage = value.image
                    self?.restartTracking()
                case .failure(_):
                    guard  !(self?.isFailOriginalOveralyImageURL ?? false) else {
//                        UIAlertController.showConfirmAlert(title: "오류", message: "AR 리소스를 다운받을 수 없습니다.")
                        return
                    }
                    self?.isFailOriginalOveralyImageURL = true
                    self?.overalyImageDownload(urlStr: urlStr)
                }
            }
        }
    }
    
    private func guideImageDownLoad(urlStr: String) {
        var guideImageUrlString = urlStr
        if (isFailOriginalTargetImageURL) {
            guideImageUrlString = guideImageUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        guard let targetImageUrl = URL(string: guideImageUrlString) else {
            return
        }
        ImageDownloader.default.downloadImage(with: targetImageUrl) { [weak self] result in
            switch result {
            case .success(let value):
                self?.guideImageView.image = value.image
                self?.restartTracking()
            case .failure(_):
                guard !self!.isFailOriginalTargetImageURL else {
//                    UIAlertController.showConfirmAlert(title: "오류", message: "AR 리소스를 다운받을 수 없습니다.")
                    return
                }
                self!.isFailOriginalTargetImageURL = true
                self?.targetImageDownLoad(urlStr: urlStr)
            }
        }
    }

    private func debug_update() {
        
        var targetImageWidth: CGFloat = 0.1
        if let targetImageWidthString = self.augmentedImageWidth {
            targetImageWidth = CGFloat(targetImageWidthString)
        } else {
            targetImageWidth = 0.1
        }
        
        self.targetImageWidth = targetImageWidth
        targetImageDownLoad(urlStr: self.augmentedImageString)
        overalyImageDownload(urlStr: self.overlayImageString)
        
        if let guideImageUrlString = self.guideImageString {
            guideImageDownLoad(urlStr: guideImageUrlString)
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
    private func startTracking() {
        let configuration = ARWorldTrackingConfiguration()
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        if let image = targetImage, let cgImage = image.cgImage, let targetImageWidth = targetImageWidth {
            let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: targetImageWidth)
            configuration.detectionImages = [referenceImage]
            helpLabelContainerView.isHidden = true
        }
        sceneView.session.run(configuration, options: options)
    }
    
    private func restartTracking() {
        sceneView.session.pause()
        startTracking()
    }
    
    @objc private func tapped(close button: UIButton) {
        completeHandler(false)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func tapped(action button: UIButton) {
//        guard let actionId = quest?.action?.id else { return }
        completeHandler(true)
        actionButton.isEnabled = false
        dismiss(animated: true)
//        dismiss(animated: true) {
//            self.actionButton.isEnabled = true
//            let missionViewController = UIApplication.shared.keyWindow?.topViewController() as? MissionViewController
//            missionViewController?.run(actionId: actionId) { (results, error) in
//                guard let results = results else { return }
//                missionViewController?.handle(actionResults: results, project: self.project, with: self.themeColor)
//            }
//        }
    }
    
    @objc func timerCallback(){
        timerCount += 1
    }
    
    @objc func clickOKOnboardingView (_ sender: UIButton) {
        self.onboardingView.removeFromSuperview()
    }
    
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = UIColor(rgb: 0x21152C)
        
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
        closeButton.setTitle("뒤로", for: .normal)
        closeButton.addTarget(self, action: #selector(tapped(close:)), for: .touchUpInside)
        
        if let startButtonTitle = self.buttonLabel {
            actionButton.setTitle(startButtonTitle, for: .normal)
        } else {
            actionButton.setTitle("확인", for: .normal)
        }
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
        
        
        view.addSubview(guideImageView)
        guideImageView.contentMode = .scaleAspectFit
        guideImageView.clipsToBounds = true
        guideImageView.backgroundColor = .clear
        guideImageView.alpha = 0.5
        guideImageView.snp.makeConstraints({ make in
            make.bottom.equalTo(buttonStack.snp.top).inset(-24)
            make.top.equalToSuperview().inset(24)
            make.left.right.equalToSuperview().inset(24)
        })
        
        helpLabelContainerView.layer.cornerRadius = 13
        helpLabelContainerView.layer.masksToBounds = true
        view.addSubview(helpLabelContainerView)
        helpLabelContainerView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(buttonStack.snp.top).offset(-16)
            make.leading.greaterThanOrEqualTo(view.readableContentGuide.snp.leading)
            make.trailing.lessThanOrEqualTo(view.readableContentGuide.snp.trailing)
            make.height.equalTo(32)
        }
        
        helpLabel.text = "AR 리소스 로딩 중..."
        helpLabel.textColor = .white
//        helpLabel.font = UIFont.notoFont(type: .regular, size: 16)
        helpLabelContainerView.contentView.addSubview(helpLabel)
        helpLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        }
        
//        onboardingView = setOnboardingView()
//        self.view.addSubview(onboardingView)
//        onboardingView.snp.makeConstraints { (view) in
//            view.edges.equalToSuperview()
//        }
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
extension QuestARImageRecognitionViewController: ARSCNViewDelegate {
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
            
            self?.timer?.invalidate()
            
            self?.actionButton.isEnabled = true
            self?.actionButton.buttonColor = UIColor(rgb: 0xC869FF)
            self?.actionButton.setTitleColor(.white, for: .normal)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 1
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            self?.guideImageView.isHidden = true
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print(anchor)
    }
}
