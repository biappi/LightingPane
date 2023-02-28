//
//  LCARS.swift
//  HK
//
//  Created by Antonio Malara on 10/12/2018.
//  Copyright © 2018 Antonio Malara. All rights reserved.
//

import UIKit

@IBDesignable
public class LCARSElbow : UIView {

    enum Position : Int {
        case topLeft     = 1
        case topRight    = 2
        case bottomRight = 3
        case bottomLeft  = 4
        
        var makePath : (CGSize, CGFloat, CGFloat, CGFloat, CGFloat) -> CGPath {
            switch self {
            case .topLeft:     return TopLeftElbow
            case .topRight:    return TopRightElbow
            case .bottomRight: return BottomRightElbow
            case .bottomLeft:  return BottomLeftElbow
            }
        }
    }

    private let shape = CAShapeLayer()
    
    var positionEnum : Position {
        return Position(rawValue: position) ?? .topLeft
    }
    
    @IBInspectable var position : Int = 1 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var elbowWidth  : CGFloat = 92 {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var elbowHeight : CGFloat = 35 {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable var bigRadius  : CGFloat = 92 {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var smallRadius : CGFloat = 35 {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable var color : UIColor = .white {
        didSet {
            shape.fillColor = color.cgColor
        }
    }

    public override func layoutSubviews() {
        shape.path = positionEnum.makePath(
            bounds.size,
            bigRadius,
            smallRadius,
            elbowWidth,
            elbowHeight
        )
        
        shape.fillColor = color.cgColor
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(
            width: elbowWidth + smallRadius,
            height: max(bigRadius, smallRadius)
        )
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(shape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.addSublayer(shape)
    }
    
}

private func TopRightElbow(
    bounds:      CGSize,
    bigRadius:   CGFloat,
    smallRadius: CGFloat,
    elbowWidth:  CGFloat,
    elbowHeight: CGFloat
    ) -> CGPath
{
    let p = CGMutablePath()
    
    p.move(to: CGPoint(x: 0, y: 0))
    p.addLine(to: CGPoint(x: bounds.width - bigRadius, y: 0))

    p.addArc(
        center: CGPoint(x: bounds.width - bigRadius,
                        y: bigRadius),
        radius: bigRadius,
        startAngle: -.pi / 2.0,
        endAngle: 0,
        clockwise: false
    )
    
    p.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
    p.addLine(to: CGPoint(x: bounds.width - elbowWidth, y: bounds.height))
    p.addLine(to: CGPoint(x: bounds.width - elbowWidth,
                          y: elbowHeight + smallRadius))

    p.addArc(
        center: CGPoint(x: bounds.width - elbowWidth - smallRadius,
                        y: elbowHeight + smallRadius),
        radius: smallRadius,
        startAngle: 0,
        endAngle: -.pi / 2,
        clockwise: true
    )
    
    p.addLine(to: CGPoint(x: 0, y: elbowHeight))
    
    return p
}

private func TopLeftElbow(
    bounds:      CGSize,
    bigRadius:   CGFloat,
    smallRadius: CGFloat,
    elbowWidth:  CGFloat,
    elbowHeight: CGFloat
    ) -> CGPath
{
    let p = CGMutablePath()
    
    p.addArc(
        center: CGPoint(x: bigRadius,
                        y: bigRadius),
        radius: bigRadius,
        startAngle: -.pi,
        endAngle: -.pi / 2.0,
        clockwise: false
    )
    
    p.addLine(to: CGPoint(x: bounds.width, y: 0))
    p.addLine(to: CGPoint(x: bounds.width, y: elbowHeight))
    p.addLine(to: CGPoint(x: elbowWidth + smallRadius,
                          y: elbowHeight))

    p.addArc(
        center: CGPoint(x: elbowWidth + smallRadius,
                        y: elbowHeight + smallRadius),
        radius: smallRadius,
        startAngle: -.pi / 2.0,
        endAngle: -.pi,
        clockwise: true
    )

    p.addLine(to: CGPoint(x: elbowWidth,
                          y: bounds.height))

    p.addLine(to: CGPoint(x: 0,
                          y: bounds.height))

    return p
}


private func BottomRightElbow(
    bounds:      CGSize,
    bigRadius:   CGFloat,
    smallRadius: CGFloat,
    elbowWidth:  CGFloat,
    elbowHeight: CGFloat
    ) -> CGPath
{
    let p = CGMutablePath()
    
    p.move(to: CGPoint(x: 0, y: bounds.height - elbowHeight))
    p.addLine(to: CGPoint(x: 0, y: bounds.height))
    
    p.addArc(
        center: CGPoint(x: bounds.width - bigRadius,
                        y: bounds.height - bigRadius),
        radius: bigRadius,
        startAngle: .pi / 2.0,
        endAngle: 0,
        clockwise: true
    )
    
    p.addLine(to: CGPoint(x: bounds.width, y: 0))
    p.addLine(to: CGPoint(x: bounds.width - elbowWidth, y: 0))
    p.addLine(to: CGPoint(x: bounds.width - elbowWidth,
                          y: bounds.height - elbowHeight - smallRadius))
    
    p.addArc(
        center: CGPoint(x: bounds.width - elbowWidth - smallRadius,
                        y: bounds.height - elbowHeight - smallRadius),
        radius: smallRadius,
        startAngle: 0,
        endAngle: .pi / 2.0,
        clockwise: false
    )
    
    return p
}

private func BottomLeftElbow(
    bounds:      CGSize,
    bigRadius:   CGFloat,
    smallRadius: CGFloat,
    elbowWidth:  CGFloat,
    elbowHeight: CGFloat
) -> CGPath
{
    let p = CGMutablePath()
    
    p.move(to: .zero)
    p.addArc(
        center: CGPoint(x: bigRadius,
                        y: bounds.height - bigRadius),
        radius: bigRadius,
        startAngle: .pi,
        endAngle: .pi / 2.0,
        clockwise: true
    )
    
    p.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
    p.addLine(to: CGPoint(x: bounds.width, y: bounds.height - elbowHeight))
    p.addLine(to: CGPoint(x: elbowWidth + smallRadius,
                          y: bounds.height - elbowHeight))
    
    p.addArc(
        center: CGPoint(x: elbowWidth + smallRadius,
                        y: bounds.height - elbowHeight - smallRadius),
        radius: smallRadius,
        startAngle: .pi / 2.0,
        endAngle: .pi,
        clockwise: false
    )
    
    p.addLine(to: CGPoint(x: elbowWidth, y: 0))

    return p
}

@IBDesignable
public class LCARSButton : UIControl {

    let label = LCARSLabel()
    
    @IBInspectable var caps : Bool = true {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable var text : String {
        set {
            label.text = newValue
            invalidateIntrinsicContentSize()
        }
        
        get {
            return label.text
        }
    }

    @IBInspectable var fontSize : CGFloat {
        set {
            label.size = newValue
            invalidateIntrinsicContentSize()
        }
        
        get {
            return label.size
        }
    }

    @IBInspectable var topMargin    : CGFloat = 0 { didSet { topConstraint?.constant    = topMargin    } }
    @IBInspectable var leftMargin   : CGFloat = 0 { didSet { leftConstraint?.constant   = leftMargin   } }
    @IBInspectable var rightMargin  : CGFloat = 0 { didSet { rightConstraint?.constant  = -rightMargin  } }
    @IBInspectable var bottomMargin : CGFloat = 0 { didSet { bottomConstraint?.constant = -bottomMargin } }

    private var topConstraint    : NSLayoutConstraint?
    private var leftConstraint   : NSLayoutConstraint?
    private var rightConstraint  : NSLayoutConstraint?
    private var bottomConstraint : NSLayoutConstraint?
    
    override public func layoutSubviews() {
        if label.superview == nil {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.color = .black
            
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .vertical)

            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .vertical)

            label.setNeedsLayout()
            label.layoutIfNeeded()
            
            addSubview(label)
            
            topConstraint    = label.topAnchor.constraint(equalTo: topAnchor, constant: topMargin)
            leftConstraint   = label.leftAnchor.constraint(equalTo: leftAnchor, constant: leftMargin)
            rightConstraint  = label.rightAnchor.constraint(equalTo: rightAnchor, constant: -rightMargin)
            bottomConstraint = label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomMargin)

            NSLayoutConstraint.activate([
                topConstraint!,
                leftConstraint!,
                rightConstraint!,
                bottomConstraint!,
            ])
        }
        
        layer.masksToBounds = true
        layer.cornerRadius = caps ? layer.bounds.height / 2.0 : 0
    }
    
}

@IBDesignable
public class LCARSUIButton : UIButton {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.font = LCARSLabel.font.withSize(titleLabel?.font.pointSize ?? 17)
    }
    
}

@IBDesignable
public class LCARSLabel : UIView {
    
    private let label = UILabel()
    private var topConstraint    : NSLayoutConstraint?
    private var bottomConstraint : NSLayoutConstraint?

    @IBInspectable public var text : String = " " {
        didSet {
            label.text = text.uppercased()
            updateLayout()
        }
    }

    @IBInspectable public var size : CGFloat = 17 {
        didSet {
            label.font = LCARSLabel.font.withSize(size)
            updateLayout()
        }
    }

    @IBInspectable public var color : UIColor = .white {
        didSet { label.textColor = color }
    }

    static public let font : UIFont = {
        UIFont.jbs_registerFont(
            withFilenameString: "Swiss 911 Ultra Compressed BT.ttf",
            bundle: Bundle(for: LCARSLabel.self)
        )
        
        return UIFont(name: "Swiss911BT-UltraCompressed", size: 17)!
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = color
        label.font = LCARSLabel.font.withSize(size)
        label.text = text.uppercased()
        addSubview(label)
        
        topConstraint = label.topAnchor.constraint(equalTo: topAnchor)
        bottomConstraint = label.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        topConstraint?.isActive = true
        bottomConstraint?.isActive = true
        
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        updateLayout()
    }
    
    private func updateLayout() {
        topConstraint?.constant = -label.font.ascender + label.font.capHeight
        bottomConstraint?.constant = -label.font.descender
        
        invalidateIntrinsicContentSize()
    }
    
}

@IBDesignable
public class LCARSStartCap : UIView {
    
    override public func layoutSubviews() {
        let x = CGMutablePath()
        x.addArc(
            center: CGPoint(x: bounds.height / 2.0,
                            y: bounds.height / 2.0),
            radius: bounds.height / 2.0,
            startAngle: .pi / 2.0,
            endAngle: .pi * 1.5,
            clockwise: false
        )
        
        x.addLine(to: CGPoint(x: bounds.width, y: 0))
        x.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        
        let shape = CAShapeLayer()
        shape.path = x
        layer.mask = shape
    }

    public override var intrinsicContentSize: CGSize {
        var size = bounds.size
        size.width = 2 * size.height
        return size
    }
}

@IBDesignable
public class LCARSEndCap : UIView {
    
    override public func layoutSubviews() {
        let x = CGMutablePath()
        x.addArc(
            center: CGPoint(x: bounds.width - bounds.height / 2.0,
                            y: bounds.height / 2.0),
            radius: bounds.height / 2.0,
            startAngle: .pi / 2.0,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        
        x.addLine(to: CGPoint(x: 0, y: 0))
        x.addLine(to: CGPoint(x: 0, y: bounds.height))
        
        let shape = CAShapeLayer()
        shape.path = x
        layer.mask = shape
    }
    
}

@IBDesignable
public class LCARSTitle : UIView {
    
    private let stackView  = UIStackView()
    private let startCap   = LCARSStartCap()
    private let endCap     = LCARSEndCap()
    private let labelLeft  = LCARSLabel()
    private let labelRight = LCARSLabel()
    private let bar        = UIView()

    private func hideLabels() {
        labelLeft.isHidden  = textHidden || !textBefore
        labelRight.isHidden = textHidden ||  textBefore
    }
    
    @IBInspectable var textBefore : Bool = true {
        didSet { hideLabels() }
    }
    
    @IBInspectable var textHidden : Bool = false {
        didSet { hideLabels() }
    }

    @IBInspectable var text : String = " " {
        didSet {
            labelLeft.text = text
            labelRight.text = text
        }
    }

    @IBInspectable var textSize : CGFloat = 50{
        didSet {
            labelLeft.size = textSize
            labelRight.size = textSize
        }
    }

    @IBInspectable var spacing : CGFloat = 5 {
        didSet { stackView.spacing = spacing }
    }

    
    @IBInspectable var colorStartCap : UIColor  {
        set { startCap.backgroundColor = newValue }
        get { return startCap.backgroundColor ?? .white }
    }

    @IBInspectable var colorText : UIColor  {
        set {
            labelLeft.color = newValue
            labelRight.color = newValue
        }
        
        get {
            return labelLeft.color
        }
    }

    @IBInspectable var colorBar : UIColor  {
        set { bar.backgroundColor = newValue }
        get { return bar.backgroundColor ?? .white }
    }

    @IBInspectable var colorEndCap : UIColor  {
        set { endCap.backgroundColor = newValue }
        get { return endCap.backgroundColor ?? .white }
    }

    override public func layoutSubviews() {
        if stackView.superview == nil {
            stackView.translatesAutoresizingMaskIntoConstraints  = false
            startCap.translatesAutoresizingMaskIntoConstraints   = false
            endCap.translatesAutoresizingMaskIntoConstraints     = false
            labelLeft.translatesAutoresizingMaskIntoConstraints  = false
            labelRight.translatesAutoresizingMaskIntoConstraints = false
            bar.translatesAutoresizingMaskIntoConstraints        = false
            
            labelLeft.text = text
            
            labelLeft.setContentHuggingPriority(.required, for: .horizontal)
            labelLeft.setContentHuggingPriority(.required, for: .vertical)
            
            labelLeft.setContentCompressionResistancePriority(.required, for: .horizontal)
            labelLeft.setContentCompressionResistancePriority(.required, for: .vertical)

            labelRight.text = text
            
            labelRight.setContentHuggingPriority(.required, for: .horizontal)
            labelRight.setContentHuggingPriority(.required, for: .vertical)
            
            labelRight.setContentCompressionResistancePriority(.required, for: .horizontal)
            labelRight.setContentCompressionResistancePriority(.required, for: .vertical)
            
            stackView.axis         = .horizontal
            stackView.alignment    = .fill
            stackView.distribution = .fill
            stackView.spacing      = spacing
            
            hideLabels()
            
            stackView.addArrangedSubview(startCap)
            stackView.addArrangedSubview(labelLeft)
            stackView.addArrangedSubview(bar)
            stackView.addArrangedSubview(labelRight)
            stackView.addArrangedSubview(endCap)
            
            addSubview(stackView)
            
            let barWidth = bar.widthAnchor.constraint(equalToConstant: 0)
            barWidth.priority = .defaultLow
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.rightAnchor.constraint(equalTo: rightAnchor),
                stackView.leftAnchor.constraint(equalTo: leftAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                endCap.widthAnchor.constraint(equalTo: endCap.heightAnchor, multiplier: 1, constant: 0),
                startCap.widthAnchor.constraint(equalTo: startCap.heightAnchor, multiplier: 1, constant: 0),
            
                barWidth,
            ])
        }
    }
    
}


@IBDesignable
public class LCARSElbowTitle : UIView {

    @IBInspectable var spacing : CGFloat = 20  {
        didSet { stackView.spacing = spacing }
    }

    @IBInspectable var elbowWidth : CGFloat {
        set { elbow.elbowWidth = newValue ; setNeedsLayout() }
        get { return elbow.elbowWidth }
    }

    @IBInspectable var elbowBigRadius : CGFloat {
        set { elbow.bigRadius = newValue ; setNeedsLayout() }
        get { return elbow.bigRadius }
    }

    @IBInspectable var elbowSmallRadius : CGFloat {
        set { elbow.smallRadius = newValue ; setNeedsLayout()  }
        get { return elbow.smallRadius }
    }
    
    @IBInspectable var text : String {
        set { label.text = newValue }
        get { return label.text }
    }
    
    @IBInspectable var textSize : CGFloat  {
        set { label.size = newValue }
        get { return label.size }
    }

    @IBInspectable var colorElbow : UIColor {
        set { elbow.color = newValue }
        get { return elbow.color }
    }
    
    @IBInspectable var colorText : UIColor  {
        set { label.color = newValue }
        get { return label.color }
    }

    @IBInspectable var colorCap : UIColor {
        set { cap.backgroundColor = newValue }
        get { return cap.backgroundColor ?? .white }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    let stackView = UIStackView()
    let elbow     = LCARSElbow()
    let label     = LCARSLabel()
    let cap       = LCARSEndCap()
    
    var labelBoundsObservation : Any?
    
    func setup() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        elbow.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        cap.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = text
        label.size = textSize
        
        cap.backgroundColor = .white
        
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = spacing
        
        stackView.addArrangedSubview(elbow)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(cap)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            elbow.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            
            cap.heightAnchor.constraint(equalTo: cap.widthAnchor),
            cap.heightAnchor.constraint(equalTo: label.heightAnchor),

            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        
        labelBoundsObservation = label.observe(\.bounds) { (l, c) in
            self.elbow.elbowHeight = l.bounds.height
        }
    }
    
}

@IBDesignable
public class LCARSGradientSlider : UIControl {
    
    let gradientLayer = CAGradientLayer()
    let panRecognizer = UIPanGestureRecognizer()
    
    let caret = UIView()

    public var progress: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }

    public var slidingActionStarted : (Bool) -> Void = { _ in }
    
    public var colors : [CGColor] {
        get { return gradientLayer.colors as? [CGColor] ?? [] }
        set { gradientLayer.colors = newValue }
    }
    
    override public func layoutSubviews() {
        if gradientLayer.superlayer == nil {
            layer.addSublayer(gradientLayer)
            
            if gradientLayer.colors == nil {
                gradientLayer.colors = (0 ..< 10)
                    .map {
                        UIColor(
                            hue: CGFloat($0) / 10,
                            saturation: 1,
                            brightness: 1,
                            alpha: 1
                            )
                            .cgColor
                }
            }
            
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            
            caret.layer.borderColor = UIColor.yellow.cgColor
            caret.layer.borderWidth = 2
            caret.layer.cornerRadius = 10
            
            gradientLayer.cornerRadius = 5
            gradientLayer.borderColor = UIColor.gray.cgColor
            gradientLayer.borderWidth = 2
            gradientLayer.masksToBounds = true
            
            self.addSubview(caret)
            
            panRecognizer.addTarget(self, action: #selector(onPan))
            self.addGestureRecognizer(panRecognizer)
        }

        caret.frame = CGRect(
            origin: CGPoint(
                x: caretCenterFor(progress: progress),
                y: 0),
            size: CGSize(
                width: bounds.width / 10,
                height: bounds.height
            )
        )

        gradientLayer.frame = layer.bounds
    }

    var caretWidth:  CGFloat { caret.frame.size.width }
    var sliderWidth: CGFloat { bounds.size.width  - caretWidth }

    func progressFor(center: CGFloat) -> CGFloat {
        return (center - (caretWidth / 2.0)) / sliderWidth
    }

    func caretCenterFor(progress: CGFloat) -> CGFloat {
        return caretWidth / 2.0 + progress * sliderWidth
    }

    @objc func onPan(sender: UIPanGestureRecognizer) {
        let l = panRecognizer.location(in: self)
        caret.center.x = l.x

        let progress = progressFor(center: caret.center.x)
        let clamped = min(max(progress, 0), 1)
        self.progress = clamped

        if sender.state == .began {
            slidingActionStarted(true)
        }
        
        sendActions(for: .valueChanged)
        
        if (sender.state == .cancelled) || (sender.state == .ended) {
            slidingActionStarted(false)
        }
    }

}

extension UIFont {
    
    static func jbs_registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }
        
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }
        
        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }
        
        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }
        
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
    
}
