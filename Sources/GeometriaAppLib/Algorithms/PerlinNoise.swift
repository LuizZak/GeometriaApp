import Geometria

/* Function to linearly interpolate between a0 and a1
 * Weight w should be in the range [0.0, 1.0]
 */
private func interpolate(_ a0: Float, _ a1: Float, _ w: Float) -> Float {
    /* // You may want clamping by inserting:
     * if (0.0 > w) return a0;
     * if (1.0 < w) return a1;
     */
    return (a1 - a0) * w + a0;
    /* // Use this cubic interpolation [[Smoothstep]] instead, for a smooth appearance:
     * return (a1 - a0) * (3.0 - w * 2.0) * w * w + a0;
     *
     * // Use [[Smootherstep]] for an even smoother result with a second derivative equal to zero on boundaries:
     * return (a1 - a0) * ((w * (w * 6.0 - 15.0) + 10.0) * w * w * w) + a0;
     */
}

/* Create pseudorandom direction vector
 */
private func randomGradient(_ ix: Int32, _ iy: Int32) -> Vector2F {
    typealias Unsigned = UInt32
    
    // No precomputed gradients mean this works for any number of grid coordinates
    let w: Unsigned = Unsigned(8 * MemoryLayout<Unsigned>.size);
    let s: Unsigned = w / 2; // rotation width
    var a = Unsigned(bitPattern: ix), b = Unsigned(bitPattern: iy)
    a &*= 3284157443; b ^= a << s | a >> w&-s;
    b &*= 1911520717; a ^= b << s | b >> w&-s;
    a &*= 2048419325;
    let random: Float = Float(a) * (3.14159265 / Float(~(~Unsigned(0) &>> 1))); // in [0, 2*Pi]
    
    return .init(x: Float.sin(random), y: Float.cos(random))
}

// Computes the dot product of the distance and gradient vectors.
private func dotGridGradient(_ ix: Int32, _ iy: Int32, _ x: Float, _ y: Float) -> Float {
    // Get gradient from integer coordinates
    let gradient = randomGradient(ix, iy)

    // Compute the distance vector
    let dx = x - Float(ix);
    let dy = y - Float(iy);

    // Compute the dot-product
    return (dx*gradient.x + dy*gradient.y);
}

func perlin(_ x: Double, _ y: Double) -> Double {
    return Double(perlin(Float(x), Float(y)))
}

// Compute Perlin noise at coordinates x, y
func perlin(_ x: Float, _ y: Float) -> Float {
    // Determine grid cell coordinates
    let x0 = Int32(x);
    let x1 = x0 + 1;
    let y0 = Int32(y)
    let y1 = y0 + 1;

    // Determine interpolation weights
    // Could also use higher order polynomial/s-curve here
    let sx = x - Float(x0);
    let sy = y - Float(y0);

    // Interpolate between grid point gradients
    var n0: Float, n1: Float, ix0: Float, ix1: Float, value: Float

    n0 = dotGridGradient(x0, y0, x, y);
    n1 = dotGridGradient(x1, y0, x, y);
    ix0 = interpolate(n0, n1, sx);

    n0 = dotGridGradient(x0, y1, x, y);
    n1 = dotGridGradient(x1, y1, x, y);
    ix1 = interpolate(n0, n1, sx);

    value = interpolate(ix0, ix1, sy);
    return value
}
