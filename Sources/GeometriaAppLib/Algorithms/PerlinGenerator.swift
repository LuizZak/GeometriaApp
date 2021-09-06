// Code derived from:
// https://github.com/lachlanhurst/perlin-swift
// The license of which is stated bellow

/*
 The MIT License (MIT)

 Copyright (c) 2015 Lachlan Hurst

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

private let PERMUTATION_SIZE = 256

class PerlinGenerator {
    
    static let global = PerlinGenerator()
    
    static let gradient:[[Int8]] = [
        [ 1, 1], [ 1, 1], [ 1, 0], [ 0, 1],
        [ 1, 1], [ 1, 1], [ 1, 0], [ 0, 1],
        [ 1,-1], [ 1,-1], [ 1, 0], [ 0, 1],
        [ 1,-1], [ 1,-1], [ 1, 0], [ 0, 1],
        [-1, 1], [-1, 1], [-1, 0], [ 0,-1],
        [-1, 1], [-1, 1], [-1, 0], [ 0,-1],
        [-1,-1], [-1,-1], [-1, 0], [ 0,-1],
        [-1,-1], [-1,-1], [-1, 0], [ 0,-1]
    ]
    
    var permut:[Int]
    
    var octaves:Int
    var persistence:Float
    var zoom:Float
    
    init(){
        permut = [Int](repeating: 0, count: PERMUTATION_SIZE)
        for i in 0..<PERMUTATION_SIZE {
            permut[i] = Int(arc4random() & 0xff)
        }
        octaves = 6
        persistence = 0.8
        zoom = .pi * 2
    }
    
    func gradientAt(i:Int, j:Int) -> Int {
        return permut[(j + permut[i & 0xff]) & 0xff] & 0x1f
    }
    
    func productOf(a:Float, b:Int8) -> Float {
        if b > 0 {
            return a
        }
        if b < 0 {
            return -a
        }
        return 0
    }
    
    func dotProductI(x0:Float, x1:Int8,
                     y0:Float, y1:Int8) -> Float {
        
        return self.productOf(a: x0, b: x1) + self.productOf(a: y0, b: y1)
    }
    
    func spline(state:Float) -> Float{
        let square = state * state
        let cubic = square * state
        return cubic * (6 * square - 15 * state + 10)
    }
    
    func interpolate(a:Float, b:Float, x:Float) -> Float {
        return a + x*(b-a)
    }
    
    func smoothNoise(x:Float, y:Float) -> Float {
        let x0 = Int(x > 0 ? x : x - 1)
        let y0 = Int(y > 0 ? y : y - 1)
        
        let x1 = x0+1
        let y1 = y0+1
        
        // The vectors
        var dx0 = x-Float(x0)
        var dy0 = y-Float(y0)
        let dx1 = x-Float(x1)
        let dy1 = y-Float(y1)
        
        // The 16 gradient values
        let g0000 = PerlinGenerator.gradient[self.gradientAt(i:x0, j: y0)]
        let g0100 = PerlinGenerator.gradient[self.gradientAt(i:x0, j: y1)]
        let g1000 = PerlinGenerator.gradient[self.gradientAt(i:x1, j: y0)]
        let g1100 = PerlinGenerator.gradient[self.gradientAt(i:x1, j: y1)]
        
        // The 16 dot products
        let b0000 = self.dotProductI(x0:dx0, x1: g0000[0], y0:dy0, y1:g0000[1])
        let b0100 = self.dotProductI(x0:dx0, x1: g0100[0], y0:dy1, y1:g0100[1])
        let b1000 = self.dotProductI(x0:dx1, x1: g1000[0], y0:dy0, y1:g1000[1])
        let b1100 = self.dotProductI(x0:dx1, x1: g1100[0], y0:dy1, y1:g1100[1])
        
        dx0 = self.spline(state:dx0)
        dy0 = self.spline(state:dy0)
        
        let b001 = self.interpolate(a:b1000, b:b1100, x:dy0)
        let b000 = self.interpolate(a:b0000, b:b0100, x:dy0)
        
        let result = self.interpolate(a:b000, b:b001, x:dx0)
        
        return result;
    }
    
    private func perlinNoise(x:Float, y:Float) -> Float{
        
        var noise:Float = 0.0
        for octave in 0..<self.octaves {
            let frequency = powf(2, Float(octave))
            let amplitude = powf(self.persistence, Float(octave))
            
            noise += self.smoothNoise(x: x * frequency / zoom,
                                      y: y * frequency / zoom) * amplitude
        }
        return noise
    }
    
    func perlinNoise(x:Double, y:Double) -> Double{
        return Double(perlinNoise(x: Float(x), y: Float(y)))
    }
}
