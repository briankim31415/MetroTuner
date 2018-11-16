//
//  FirstViewController.swift
//  MetroTuner
//
//  Created by Kim, Brian M on 10/19/18.
//  Copyright © 2018 Kim, Brian M. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var dial: UIImageView!
    @IBOutlet weak var tempoBox: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rotation = 0
        rotate(to: rotation)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var inRadius: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: view)
        testRadius(location)
    }
    
    func angle(from location: CGPoint) -> CGFloat {
        let deltaY = location.y - dial.center.y
        let deltaX = location.x - dial.center.x
        let angle = atan2(deltaY, deltaX) * 180 / .pi
        print(angle)
        return angle < 0 ? abs(angle) : 360 - angle
    }
    
    private var rotation: CGFloat = UserDefaults.standard.rotation
    private var startRotationAngle: CGFloat = 0
    
    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        let gestureRotation = CGFloat(angle(from: location)) - startRotationAngle
        if inRadius == true {
            switch gesture.state {
            case .began:
                startRotationAngle = angle(from: location)
            case .changed:
                rotate(to: rotation - gestureRotation.degreesToRadians)
                //self.tempoBox.text = "\(rotation(location))"
            case .ended:
                rotation -= gestureRotation.degreesToRadians
            default :
                break
            }
            UserDefaults.standard.rotation = rotation
        }
    }
    
    private let rotateAnimation = CABasicAnimation()
    func rotate(to: CGFloat, duration: Double = 0) {
        rotateAnimation.fromValue = to
        rotateAnimation.toValue = to
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = 0
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.fillMode = kCAFillModeForwards
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        dial.layer.add(rotateAnimation, forKey: "transform.rotation.z")
    }
    
    func testRadius(_ position: CGPoint) {
        let radius: Double = dial.frame.height.native / 2
        let fingerDistance = (pow(Double(position.x - dial.center.x), 2.0) + pow(Double(position.y - dial.center.y), 2.0)).squareRoot()
        if radius >= fingerDistance {
            inRadius = true
        } else {
            inRadius = false
        }
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180}
    var radiansToDegrees: Self { return self * 180 / .pi}
}

extension UserDefaults {
    var rotation: CGFloat {
        get {
            return CGFloat(double(forKey: "rotation"))
        }
        set {
            set(Double(newValue), forKey: "rotation")
        }
    }
}
