import SwiftBlend2D

@_transparent
public func mix(_ color1: BLRgba32, _ color2: BLRgba32, factor: Double) -> BLRgba32 {
    return mergeColors(color1, color2, factor: Float(factor))
}

@_transparent
public func mergeColors(_ color1: BLRgba32, _ color2: BLRgba32, factor: Double) -> BLRgba32 {
    return mergeColors(color1, color2, factor: Float(factor))
}

@_transparent
public func mergeColors(_ color1: BLRgba32, _ color2: BLRgba32, factor: Float) -> BLRgba32 {
    if factor <= 0 {
        return color1
    }
    if factor >= 1 {
        return color2
    }
    if color2 == BLRgba.transparentBlack {
        return color1
    }
    
    return color1.faded(towards: color2, factor: factor)
}
