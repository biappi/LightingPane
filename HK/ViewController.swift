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
    
    @IBOutlet var dayName: LCARSLabel!
    @IBOutlet var date: LCARSLabel!
    @IBOutlet var time: LCARSLabel!
    
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
        dayName.text = dayFormatter.string(from: now)
        date.text    = dateFormatter.string(from: now)
        time.text    = clockFormatter.string(from: now)
    }
    
}

protocol ColorControllerDelegateParent : AnyObject {
    func colorControllerDelegate(_ delegate: ColorControllerDelegate, didChangeColor to: HSV)
}

protocol ColorControllerDelegate : AnyObject {
    var weakParent : ColorControllerDelegateParent? { get set }
    func sendColor(_ hsv: HSV)
}

class ColorController : NSObject, ColorControllerDelegateParent {
    
    @IBOutlet var brightness:   LCARSGradientSlider!
    @IBOutlet var hue:          LCARSGradientSlider!
    @IBOutlet var saturation:   LCARSGradientSlider!
    
    @IBOutlet var colorPreview: UIView!
    
    var hsv = HSV.zero
    
    weak var delegate : ColorControllerDelegate? {
        didSet {
            delegate?.weakParent = self
        }
    }
    
    func updateGradients(hsv: HSV) {
//        colorPreview.backgroundColor = UIColor(hsv)
        
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
    
    var hueCharacteristic        : HMCharacteristic?
    var brightnessCharacteristic : HMCharacteristic?
    var saturationCharacteristic : HMCharacteristic?
    
    var service : HMService? {
        didSet {
            hueCharacteristic        = service?.characteristics.first { $0.characteristicType == "00000013-0000-1000-8000-0026BB765291" }
            brightnessCharacteristic = service?.characteristics.first { $0.characteristicType == "00000008-0000-1000-8000-0026BB765291" }
            saturationCharacteristic = service?.characteristics.first { $0.characteristicType == "0000002F-0000-1000-8000-0026BB765291" }
            
            service?.accessory?.delegate = self
            
            hueCharacteristic?.enableNotification(true)        { e in printError(e) }
            brightnessCharacteristic?.enableNotification(true) { e in printError(e) }
            saturationCharacteristic?.enableNotification(true) { e in printError(e) }
            
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
        changeColorFromAccessory()
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
    
}

class DoubleAccessoryColorControllerDelegate : NSObject, ColorControllerDelegate, ColorControllerDelegateParent {
    
    weak var weakParent: ColorControllerDelegateParent?
    
    var accessoryDelegate1 = AccessoryColorControllerDelegate()
    var accessoryDelegate2 = AccessoryColorControllerDelegate()
    
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
}

class ViewController: UIViewController, HMHomeManagerDelegate {

    let hm = HMHomeManager()
    
    let mainColorControllerDelegate   = DoubleAccessoryColorControllerDelegate()
    let accentColorControllerDelegate = AccessoryColorControllerDelegate()
    
    @IBOutlet weak var clockDay:    LCARSLabel!
    @IBOutlet weak var clockDate:   LCARSLabel!
    @IBOutlet weak var clockTime:   LCARSLabel!
    
    @IBOutlet var colorController:  ColorController!
    @IBOutlet var accentController: ColorController!
    
    var lightstripService:   HMService?
    var bedsideService:      HMService?
    var roadsideService:     HMService?
    var internalsideService: HMService?

    override func viewDidLoad() {
        super.viewDidLoad()
        hm.delegate = self

        view.layoutIfNeeded()
        
        colorController.delegate  = mainColorControllerDelegate
        accentController.delegate = accentColorControllerDelegate
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        let services = manager.primaryHome?.accessories.flatMap { $0.services } ?? []
        
        lightstripService   = services.first { $0.uniqueIdentifier == lightstripUUID   }
        bedsideService      = services.first { $0.uniqueIdentifier == bedsideUUID      }
        roadsideService     = services.first { $0.uniqueIdentifier == roadsideUUID     }
        internalsideService = services.first { $0.uniqueIdentifier == internalsideUUID }

        mainColorControllerDelegate.accessoryDelegate1.service = roadsideService
        mainColorControllerDelegate.accessoryDelegate2.service = internalsideService
        
        accentColorControllerDelegate.service = lightstripService
        
        dump(services.map { "\($0.name) \($0.uniqueIdentifier) \($0.localizedDescription) \($0.serviceType)" })
    }
    
}

let lightstripUUID   = UUID(uuidString: "9B04712C-88C9-55C7-BD2B-B831732568A6")!
let bedsideUUID      = UUID(uuidString: "B64D98A5-B423-5B2A-BC11-690CD7D9E8B5")!
let roadsideUUID     = UUID(uuidString: "363EFF22-CA03-5ED0-8304-C077CB20D9D8")!
let internalsideUUID = UUID(uuidString: "885D77EB-4292-5C34-955A-48F261BDB7AD")!
