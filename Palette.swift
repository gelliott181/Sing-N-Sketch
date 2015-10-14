//
//  Palette.swift
//  Sing N Sketch
//
//  Created by Grant D Elliott on 10/7/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation

class Palette {
    class Channel {
        var values = [Float: CGFloat]()
        
        required init() {
            addMapping(0, value: CGFloat(0))
        }
        
        
        func addMapping(frequency: Float, value: CGFloat) {
            
        }
        
        // Return a value unique to the given frequency
        func getValue(frequency: Float) -> CGFloat {
            var val: CGFloat = -1
            
            var lastFrequency: Float = 0
            var lastValue: CGFloat = 0
            
            // Return the automatically defined
            // zero hertz frequency mapping if 
            // the dictionay is somehow empty
            if values.count < 1 {
                return CGFloat(0)
            }
            if values.count == 1 {
                var val: CGFloat! = values[Float(0)]
                return val
            }
            
            // Find the matching target value, or interpolate the value from
            // the surrounding frequencies.
            for (f, v) in values {
                if f < frequency - 0.05 {
                    // Store the last frequency and
                    // the last color value checked
                    // then continue
                    lastFrequency = f
                    lastValue = v
                    continue;
                }
                // Generate the next frequency
                // then break to return
                else if frequency > f + 0.05 {
                        // Interpolate the value of the color channel
                        var ratio: CGFloat = CGFloat((frequency - lastFrequency) / (f - lastFrequency))
                        val = lastValue + ((v - lastValue) * ratio)
                        break;
                    }
                    // Return the mapped value for the
                    // given frequency +/- 0.05
                    else {
                        return v;
                    }
                
            }
            
            return val
        }
    }
    
    var red: Channel!
    var green: Channel!
    var blue: Channel!
    
    required init() {
        // Color channels
        let red = Channel()
        let green = Channel()
        let blue = Channel()
    }
    
    // Return a mapped UIColor
    func getColor(frequency: Float) -> UIColor {
        
        let r = red.getValue(frequency)
        let g = green.getValue(frequency)
        let b = blue.getValue(frequency)
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
        return color
    }
    
    func addColor(frequency: Float, r: CGFloat, g: CGFloat, b: CGFloat) {
        red.addMapping(frequency, value: r)
        green.addMapping(frequency, value: g)
        blue.addMapping(frequency, value: b)
    }
    
}