//
//  bikip.swift
//  Buoi7_UIIImageView_2
//
//  Created by PhongLe on 8/1/16.
//  Copyright © 2016 PhongLe. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImageOnline(imageLink link: String) {
        if let url:URL = URL(string: link){
            do {
                let data:Data = try Data(contentsOf: url)
                self.image = UIImage(data: data)
            }catch{
                
            }
        }
    }
    func makeCircleImageView(){
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
    }
    
    
    
    func rotateView(rotateDuration duration: Double, rotationAnimation: inout CABasicAnimation) {
        let rotationImageKey = "com.phonglnh.appSong"
        if self.layer.animation(forKey: rotationImageKey) == nil {
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float(M_PI * 2.0)
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            self.layer.add(rotationAnimation, forKey: rotationImageKey)
            
        }
    }
    
    func pauseLayer() {
        let pausedTime = self.layer.convertTime(CACurrentMediaTime(), from: nil)
        self.layer.speed = 0.0
        self.layer.timeOffset = pausedTime
    }
    
    func resumeLayer() {
        let pausedTime = self.layer.timeOffset
        self.layer.speed = 1.0
        self.layer.timeOffset = 0.0
        self.layer.beginTime = 0.0
        let timeSincePause = self.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.layer.beginTime = timeSincePause
    }
    
}

extension UIButton {
    func makeCircleGhostButton() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blue.cgColor
        self.tintColor = UIColor.blue
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        
    }
    func makeGhostButton(borderWidth: CGFloat, color: UIColor, cornerRadius: CGFloat?){
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
        self.tintColor = color
        self.layer.cornerRadius = cornerRadius ?? 0
        
        
    }
}

//0.5 * self.bounds.size.width
