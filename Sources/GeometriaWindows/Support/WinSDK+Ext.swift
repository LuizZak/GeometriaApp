import WinSDK

@_transparent
internal func LOWORD<T: FixedWidthInteger>(_ dword: T) -> WORD {
    return WORD(DWORD_PTR(dword) >>  0 & 0xffff)
}

@_transparent
internal func HIWORD<T: FixedWidthInteger>(_ dword: T) -> WORD {
    return WORD(DWORD_PTR(dword) >> 16 & 0xffff)
}
