#if false

import SwiftBlend2D

public enum Fonts {
    private static var _fontCache: [Float: BLFont] = [:]
    
    static var defaultFontFace: BLFontFace?
    
    public static var fontFilePath: String = "Resources/NotoSans-Regular.ttf"
    
    public static func defaultFont(size: Float) -> BLFont {
        guard let fontFace = defaultFontFace else {
            fatalError("Called Fonts.defaultFont(size:) before setting Fonts.defaultFontFace")
        }
        
        if let cached = _fontCache[size] {
            return cached
        }
        
        let font = BLFont(fromFace: fontFace, size: size)
        _fontCache[size] = font
        
        return font
    }
}

#endif
