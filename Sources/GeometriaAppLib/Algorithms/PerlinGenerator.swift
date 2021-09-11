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

private let permutation: [Int] = [
    151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140,
    36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120,
    234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88,
    237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134,
    139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230,
    220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1,
    216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116,
    188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124,
    123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16,
    58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163,
    70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110,
    79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193,
    238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107,
    49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45,
    127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128,
    195, 78, 66, 215, 61, 156, 180
]

class PerlinGenerator {
    static let global = PerlinGenerator()
    
    private static let gradient:[[Int8]] = [
        [ 1, 1], [ 1, 1], [ 1, 0], [ 0, 1],
        [ 1, 1], [ 1, 1], [ 1, 0], [ 0, 1],
        [ 1,-1], [ 1,-1], [ 1, 0], [ 0, 1],
        [ 1,-1], [ 1,-1], [ 1, 0], [ 0, 1],
        [-1, 1], [-1, 1], [-1, 0], [ 0,-1],
        [-1, 1], [-1, 1], [-1, 0], [ 0,-1],
        [-1,-1], [-1,-1], [-1, 0], [ 0,-1],
        [-1,-1], [-1,-1], [-1, 0], [ 0,-1]
    ]
    
    var octaves: Int
    var persistence: Float
    var zoom: Float
    
    init() {
        octaves = 6
        persistence = 0.8
        zoom = .pi * 2
    }
    
    func perlinNoise(x: Double, y: Double) -> Double {
        Double(perlinNoise(x: Float(x), y: Float(y)))
    }
    
    private func gradientAt(i: Int, j: Int) -> Int {
        permutation[(j + permutation[i & 0xff]) & 0xff] & 0x1f
    }
    
    private func productOf(a: Float, b: Int8) -> Float {
        if b > 0 {
            return a
        }
        if b < 0 {
            return -a
        }
        return 0
    }
    
    private func dotProductI(x0: Float, x1: Int8, y0: Float, y1: Int8) -> Float {
        self.productOf(a: x0, b: x1) + self.productOf(a: y0, b: y1)
    }
    
    private func spline(state: Float) -> Float {
        let square = state * state
        let cubic = square * state
        return cubic * (6 * square - 15 * state + 10)
    }
    
    private func interpolate(a: Float, b: Float, x: Float) -> Float {
        a + x * (b - a)
    }
    
    private func smoothNoise(x: Float, y: Float) -> Float {
        let x0 = Int(x > 0 ? x : x - 1)
        let y0 = Int(y > 0 ? y : y - 1)
        
        let x1 = x0 + 1
        let y1 = y0 + 1
        
        // The vectors
        var dx0 = x - Float(x0)
        var dy0 = y - Float(y0)
        let dx1 = x - Float(x1)
        let dy1 = y - Float(y1)
        
        // The 16 gradient values
        let g0000 = PerlinGenerator.gradient[gradientAt(i: x0, j: y0)]
        let g0100 = PerlinGenerator.gradient[gradientAt(i: x0, j: y1)]
        let g1000 = PerlinGenerator.gradient[gradientAt(i: x1, j: y0)]
        let g1100 = PerlinGenerator.gradient[gradientAt(i: x1, j: y1)]
        
        // The 16 dot products
        let b0000 = dotProductI(x0: dx0, x1: g0000[0], y0: dy0, y1: g0000[1])
        let b0100 = dotProductI(x0: dx0, x1: g0100[0], y0: dy1, y1: g0100[1])
        let b1000 = dotProductI(x0: dx1, x1: g1000[0], y0: dy0, y1: g1000[1])
        let b1100 = dotProductI(x0: dx1, x1: g1100[0], y0: dy1, y1: g1100[1])
        
        dx0 = spline(state: dx0)
        dy0 = spline(state: dy0)
        
        let b001 = interpolate(a: b1000, b: b1100, x: dy0)
        let b000 = interpolate(a: b0000, b: b0100, x: dy0)
        
        return interpolate(a: b000, b: b001, x: dx0)
    }
    
    private func perlinNoise(x: Float, y: Float) -> Float {
        var noise: Float = 0.0
        for octave in 0..<octaves {
            let frequency = powf(2, Float(octave))
            let amplitude = powf(persistence, Float(octave))
            
            noise += smoothNoise(x: x * frequency / zoom,
                                 y: y * frequency / zoom) * amplitude
        }
        return noise
    }
}
