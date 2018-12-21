//
//  ViewController.swift
//  HK
//
//  Created by Antonio Malara on 10/12/2018.
//  Copyright © 2018 Antonio Malara. All rights reserved.
//

import UIKit
import HomeKit
import CoreLCARS

func printError(_ error: Error?, file: String = #file, line: Int = #line) {
    guard let e = error else { return }
    print("Error \(file):\(line): \(e)")
}

struct HSV {
    let h: CGFloat
    let s: CGFloat
    let v: CGFloat
    
    static let zero = HSV(0, 0, 0)
}

extension HSV {
    
    init(_ h: CGFloat, _ s: CGFloat, _ v: CGFloat) {
        self.init(h: h, s: s, v: v)
    }
    
    func changing(h: CGFloat?, s: CGFloat?, v: CGFloat?) -> HSV {
        return HSV(
            h ?? self.h,
            s ?? self.s,
            v ?? self.v
        )
    }

    var cgColor : CGColor {
        return UIColor(self).cgColor
    }

}

extension UIColor {
    
    convenience init(_ hsv: HSV) {
        self.init(
            hue:        hsv.h,
            saturation: hsv.s,
            brightness: hsv.v,
            alpha:      1
        )

    }
    
    var hsv : HSV {
        var h = CGFloat(0)
        var s = CGFloat(0)
        var v = CGFloat(0)
        
        getHue(&h, saturation: &s, brightness: &v, alpha: nil)

        return HSV(h, s, v)
    }
 
}

class ClockController : NSObject {
    
    
    @IBOutlet var dayName: LCARSLabel?
    @IBOutlet var date: LCARSLabel?
    @IBOutlet var clock: LCARSLabel?
    @IBOutlet var longDate: LCARSLabel?
    
    var dayFormatter = DateFormatter()
    var dateFormatter = DateFormatter()
    var clockFormatter = DateFormatter()

    override func awakeFromNib() {
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
        dayFormatter.dateFormat = "EEEE"
        dateFormatter.dateFormat = "d MMMM"
        clockFormatter.dateFormat = "HH:mm"
        
        DispatchQueue.main.async {
          self.updateClock()
        }
    }
    
    @objc func updateClock() {
        let now = Date()
        
        dayName?.text = dayFormatter.string(from: now)
        date?.text = dateFormatter.string(from: now)
        clock?.text = clockFormatter.string(from: now)
        longDate?.text = "\(dayFormatter.string(from: now)) • \(dateFormatter.string(from: now))"
    }
    
}

protocol ColorControllerDelegateParent : AnyObject {
    func colorControllerDelegate(_ delegate: ColorControllerDelegate, didChangeColor to: HSV)
    func colorControllerDelegate(_ delegate: ColorControllerDelegate, didChangePower to: Bool)
}

protocol ColorControllerDelegate : AnyObject {
    var weakParent : ColorControllerDelegateParent? { get set }
    func sendColor(_ hsv: HSV)
}

class ColorController : NSObject, ColorControllerDelegateParent {
    
    @IBOutlet var brightness:   LCARSGradientSlider!
    @IBOutlet var hue:          LCARSGradientSlider!
    @IBOutlet var saturation:   LCARSGradientSlider!
    
    var hsv = HSV.zero
    var power = false
    
    weak var delegate : ColorControllerDelegate? {
        didSet {
            delegate?.weakParent = self
        }
    }
    
    func updateGradients(hsv: HSV) {
        hue.colors = (0 ..< 10)
            .map { hsv.changing(h: CGFloat($0) / 10, s: nil, v: nil).cgColor }

        saturation.colors = (0 ..< 10)
            .map { hsv.changing(h: nil, s: CGFloat($0) / 10, v: nil).cgColor }
        
        brightness.colors = (0 ..< 10)
            .map { hsv.changing(h: nil, s: nil, v: CGFloat($0) / 10).cgColor }
    }
    
    func colorControllerDelegate(_ delegate: ColorControllerDelegate, didChangeColor to: HSV) {
        hsv = to
        
        updateGradients(hsv: to)
        
        hue       .theValue = to.h
        saturation.theValue = to.s
        brightness.theValue = to.v
    }
    
    func colorControllerDelegate(_ delegate: ColorControllerDelegate, didChangePower to: Bool) {
        power = false
    }

    func changeColorFromSlider(h: CGFloat?, s: CGFloat?, v: CGFloat?) {
        delegate?.sendColor(hsv.changing(h: h, s: s, v: v))
    }
    
    @IBAction func mainHueChanged(_ sender: LCARSGradientSlider) {
        changeColorFromSlider(h: sender.theValue, s: nil, v: nil)
    }
    
    @IBAction func mainSaturationChanged(_ sender: LCARSGradientSlider) {
        changeColorFromSlider(h: nil, s: sender.theValue, v: nil)
    }

    @IBAction func mainBrightnessChanged(_ sender: LCARSGradientSlider) {
        changeColorFromSlider(h: nil, s: nil, v: sender.theValue)
    }
    
}

class Debouncer<T> : NSObject {
    
    var realAction : (T) -> Void = { _ in }
    
    private var debouncing = false
    private var thing : T?
    
    let debounceInterval = 0.2
    
    func action(_ thing: T) {
        if !debouncing {
            realAction(thing)
            debouncing = true
            
            perform(#selector(debounceTick), with: nil, afterDelay: debounceInterval)
        }
        else {
            self.thing = thing
        }
    }
    
    @objc func debounceTick() {
        if let thing = self.thing {
            realAction(thing)
            self.thing = nil
            perform(#selector(debounceTick), with: nil, afterDelay: debounceInterval)
        }
        else {
            debouncing = false
        }
    }

}

class AccessoryColorControllerDelegate : NSObject, HMAccessoryDelegate, ColorControllerDelegate {
    weak var weakParent: ColorControllerDelegateParent?
    
    var powerCharacteristic      : HMCharacteristic?
    var hueCharacteristic        : HMCharacteristic?
    var brightnessCharacteristic : HMCharacteristic?
    var saturationCharacteristic : HMCharacteristic?
    
    var onChangePower : (Bool) -> Void = { _ in }

    var service : HMService? {
        didSet {
            powerCharacteristic      = service?.characteristics.first { $0.characteristicType == "00000025-0000-1000-8000-0026BB765291" }
            hueCharacteristic        = service?.characteristics.first { $0.characteristicType == "00000013-0000-1000-8000-0026BB765291" }
            brightnessCharacteristic = service?.characteristics.first { $0.characteristicType == "00000008-0000-1000-8000-0026BB765291" }
            saturationCharacteristic = service?.characteristics.first { $0.characteristicType == "0000002F-0000-1000-8000-0026BB765291" }
            
            service?.accessory?.delegate = self
            
            powerCharacteristic?.enableNotification(true)      { e in printError(e) }
            hueCharacteristic?.enableNotification(true)        { e in printError(e) }
            brightnessCharacteristic?.enableNotification(true) { e in printError(e) }
            saturationCharacteristic?.enableNotification(true) { e in printError(e) }
            
            powerCharacteristic?.readValue       { e in self.changePowerFromAccessory(); printError(e) }
            hueCharacteristic?.readValue         { e in self.changeColorFromAccessory(); printError(e) }
            brightnessCharacteristic?.readValue  { e in self.changeColorFromAccessory(); printError(e) }
            saturationCharacteristic?.readValue  { e in self.changeColorFromAccessory(); printError(e) }
        }
    }
    
    let sendDebouncer = Debouncer<HSV>()
    
    override init() {
        super.init()
        sendDebouncer.realAction = { [weak self] in self?.realSendColor(hsv: $0) }
    }
    
    func changePowerFromAccessory() {
        weakParent?.colorControllerDelegate(self, didChangePower: powerCharacteristic?.value as? Bool ?? false)
        onChangePower(powerCharacteristic?.value as? Bool ?? false)
    }
    
    func changeColorFromAccessory() {
        weakParent?.colorControllerDelegate(
            self,
            didChangeColor: HSV(
                h: ((hueCharacteristic?       .value as? CGFloat) ?? 0) / 360.0,
                s: ((saturationCharacteristic?.value as? CGFloat) ?? 0) / 100.0,
                v: ((brightnessCharacteristic?.value as? CGFloat) ?? 0) / 100.0
            )
        )
    }
    
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        if characteristic.characteristicType == "00000025-0000-1000-8000-0026BB765291" {
            changePowerFromAccessory()
        }
        else {
            changeColorFromAccessory()
        }
    }

    func sendColor(_ hsv: HSV) {
        sendDebouncer.action(hsv)
    }
    
    func realSendColor(hsv: Any) {
        let color = hsv as! HSV
        
        hueCharacteristic?       .writeValue(Int(color.h * 360)) { e in self.changeColorFromAccessory(); printError(e) }
        saturationCharacteristic?.writeValue(Int(color.s * 100)) { e in self.changeColorFromAccessory(); printError(e) }
        brightnessCharacteristic?.writeValue(Int(color.v * 100)) { e in self.changeColorFromAccessory(); printError(e) }
    }
    
    func sendPower(_ power: Bool) {
        powerCharacteristic?.writeValue(power) { e in self.changePowerFromAccessory(); printError(e) }
    }
}

class DoubleAccessoryColorControllerDelegate : NSObject, ColorControllerDelegate, ColorControllerDelegateParent {
    
    weak var weakParent: ColorControllerDelegateParent?
    
    var accessoryDelegate1 = AccessoryColorControllerDelegate()
    var accessoryDelegate2 = AccessoryColorControllerDelegate()
    
    var onChangePower : (Bool) -> Void = { _ in }
    
    var power1 = false
    var power2 = false
    
    override init() {
        super.init()
        
        accessoryDelegate1.weakParent = self
        accessoryDelegate2.weakParent = self
    }
    
    func sendColor(_ hsv: HSV) {
        accessoryDelegate1.sendColor(hsv)
        accessoryDelegate2.sendColor(hsv)
    }
    
    func colorControllerDelegate(_ delegate: ColorControllerDelegate, didChangeColor to: HSV) {
        guard delegate === accessoryDelegate1 else { return }
        weakParent?.colorControllerDelegate(self, didChangeColor: to)
    }
    
    func colorControllerDelegate(_ delegate: ColorControllerDelegate, didChangePower to: Bool) {
        if      delegate === accessoryDelegate1 { power1 = to }
        else if delegate === accessoryDelegate2 { power2 = to }
        
        weakParent?.colorControllerDelegate(self, didChangePower: power1 || power2)
        onChangePower(power1 || power2)
    }
    
    func sendPower(_ power: Bool) {
        accessoryDelegate1.sendPower(power)
        accessoryDelegate2.sendPower(power)
    }
    
}

class ViewController: UIViewController, HMHomeManagerDelegate {

    let hm = HMHomeManager()
    
    let mainColorControllerDelegate   = DoubleAccessoryColorControllerDelegate()
    let accentColorControllerDelegate = AccessoryColorControllerDelegate()
    
    @IBOutlet var clockController:  ClockController!
    @IBOutlet var colorController:  ColorController!
    @IBOutlet var accentController: ColorController!
    
    @IBOutlet var standbyView: UIView!
    
    var lightstripService:   HMService?
    var roadsideService:     HMService?
    var internalsideService: HMService?

    var powerMain = false {
        didSet { lightsPowerDidChange() }
    }
    
    var powerAccent = false{
        didSet { lightsPowerDidChange() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hm.delegate = self

        view.layoutIfNeeded()
        
        colorController.delegate  = mainColorControllerDelegate
        accentController.delegate = accentColorControllerDelegate
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(standbyViewDidTap))
        standbyView.addGestureRecognizer(tapGesture)
        standbyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(standbyView)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: standbyView.topAnchor),
            view.leftAnchor.constraint(equalTo: standbyView.leftAnchor),
            view.rightAnchor.constraint(equalTo: standbyView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: standbyView.bottomAnchor),
        ])
        
        mainColorControllerDelegate.onChangePower = {
            [weak self] in self?.powerMain = $0
        }
        
        accentColorControllerDelegate.onChangePower = {
            [weak self] in self?.powerAccent = $0
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        let services = manager.primaryHome?.accessories.flatMap { $0.services } ?? []
        
        lightstripService   = services.first { $0.uniqueIdentifier == lightstripUUID   }
        roadsideService     = services.first { $0.uniqueIdentifier == roadsideUUID     }
        internalsideService = services.first { $0.uniqueIdentifier == internalsideUUID }

        mainColorControllerDelegate.accessoryDelegate1.service = roadsideService
        mainColorControllerDelegate.accessoryDelegate2.service = internalsideService
        
        accentColorControllerDelegate.service = lightstripService
        
        dump(services.map { "\($0.name) \($0.uniqueIdentifier) \($0.localizedDescription) \($0.serviceType)" })
        dump(roadsideService?.characteristics.map { "\($0.characteristicType) \($0.metadata!) \($0.description)" })
    }
    
    @objc func standbyViewDidTap() {
        mainColorControllerDelegate.sendPower(true)
        accentColorControllerDelegate.sendPower(true)
        hideStandbyView()
    }

    @IBAction func allLightsOffDidTap(_ sender: Any) {
        mainColorControllerDelegate.sendPower(false)
        accentColorControllerDelegate.sendPower(false)
    }
    
    // -- //
    
    private func showStandbyView() {
        UIView.animate(withDuration: 0.3) {
            self.standbyView.alpha = 1
        }
    }
    
    private func hideStandbyView() {
        UIView.animate(withDuration: 0.3) {
            self.standbyView.alpha = 0
        }
    }
    
    // -- //
    
    func lightsPowerDidChange() {
        let inStandby    = standbyView.alpha == 1
        let anyLightOn   =  powerAccent ||  powerMain
        let allLightsOff = !powerAccent && !powerMain
        
        if anyLightOn && inStandby {
            hideStandbyView()
        }
        else if allLightsOff && !inStandby {
            showStandbyView()
        }
    }
}

let lightstripUUID   = UUID(uuidString: "C10389A5-B9BC-53B0-8F24-5FF4685AE82E")!
let roadsideUUID     = UUID(uuidString: "1AA24C16-346D-5936-BE54-20A6CB0118C3")! // UUID(uuidString: "363EFF22-CA03-5ED0-8304-C077CB20D9D8")!
let internalsideUUID = UUID(uuidString: "F3FD5A39-513F-52CD-85B2-3FC5D5915826")! // UUID(uuidString: "885D77EB-4292-5C34-955A-48F261BDB7AD")!
