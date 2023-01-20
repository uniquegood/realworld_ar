//
//  SolidButton.swift
//  realworld_ar
//
//  Created by Channoori Park on 2023/01/20.
//

import UIKit
import SnapKit

class SolidButton: UIButton {
    enum buttonStyle {
        case primary
        case normal
    }
    var buttonColor: UIColor = .white {
        didSet { backgroundView.backgroundColor = buttonColor }
    }
//    private var titleColor: UIColor = .black
    private var disabledTitleColor: UIColor = UIColor.init(rgb: 0xC3C3C3)
    
    private var buttonStyle: buttonStyle = .normal
    
    
    
    private lazy var backgroundView = UIView()
    private lazy var stackView = UIStackView()
    private lazy var leadingImageView = UIImageView()
    private lazy var label = UILabel()
    private lazy var trailingImageView = UIImageView()
    
    private var textAlignmentObserver: NSKeyValueObservation?
    
    override var isHighlighted: Bool {
        didSet {
            backgroundView.alpha = isHighlighted == true ? 0.85 : 1
        }
    }
    
    var titleColor: UIColor = .black {
        didSet { label.textColor = titleColor }
    }
    override var isEnabled: Bool {
        didSet {
            if isEnabled == true {
                alpha = 1
                label.textColor = titleColor
            } else {
                alpha = 1
                label.textColor = disabledTitleColor
            }
        }
    }
    
    
    // MARK: - View
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(_ style: buttonStyle = .normal) {
        self.init()
        self.buttonStyle = style
    }
    
    // MARK: - Action
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        label.text = title
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        if state == .disabled {
            disabledTitleColor = color ?? .lightGray
        } else {
            titleColor = color ?? .black
        }
        updateTitleColor()
    }
    
    private func updateTitleColor() {
        label.textColor = state == .disabled ? disabledTitleColor : titleColor
    }
    
    // MARK: - Setup
    private func setup() {
        backgroundView.isUserInteractionEnabled = false
        backgroundView.backgroundColor = buttonColor
        backgroundView.layer.cornerRadius = 23
        backgroundView.layer.masksToBounds = true
        insertSubview(backgroundView, at: 0)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 6
        backgroundView.addSubview(stackView)
        stackView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().inset(4)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(4)
        })
        
        titleLabel?.removeFromSuperview()
        stackView.addArrangedSubview(leadingImageView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(trailingImageView)
        
        setLeading(image: nil)
        leadingImageView.contentMode = .scaleAspectFit
        leadingImageView.tintColor = .black
        leadingImageView.snp.makeConstraints { (make) in
            make.width.equalTo(leadingImageView.snp.height)
            make.height.equalTo(stackView.snp.height).inset(9)
        }
        
//        label.font = UIFont.notoFont(type: .regular, size: 15)
        
        label.snp.makeConstraints { (view) in
            view.left.right.equalToSuperview()
        }
        
        setTrailing(image: nil)
        leadingImageView.contentMode = .scaleAspectFit
        trailingImageView.tintColor = .black
        trailingImageView.snp.makeConstraints { (make) in
            make.width.equalTo(trailingImageView.snp.height)
            make.height.equalTo(stackView.snp.height).inset(9)
        }
        
        textAlignmentObserver = titleLabel?.observe(\.textAlignment, changeHandler: { [weak self] (titleLabel, _) in
            self?.label.textAlignment = titleLabel.textAlignment
        })
    }
    
    // MARK: - Action
    func setLeading(image: UIImage?, tintColor: UIColor? = .black) {
        leadingImageView.tintColor = tintColor
        leadingImageView.image = image
        leadingImageView.isHidden = image == nil ? true : false
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func setTrailing(image: UIImage?, tintColor: UIColor? = .black) {
        trailingImageView.tintColor = tintColor
        trailingImageView.image = image
        trailingImageView.isHidden = image == nil ? true : false
        setNeedsLayout()
        layoutIfNeeded()
    }
    func resetCornerRadius(_ radius: CGFloat) {
        backgroundView.layer.cornerRadius = radius
    }
    
    func setFont(_ font: UIFont) {
        label.font = font
    }
}

