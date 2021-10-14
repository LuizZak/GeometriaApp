import WinSDK

struct CD3DX12_CPU_DESCRIPTOR_HANDLE: Hashable {
    var handle: D3D12_CPU_DESCRIPTOR_HANDLE

    mutating func offset(_ offsetInDescriptors: Int, _ descriptorIncrementSize: Int) {
        handle.ptr += UINT64(offsetInDescriptors) + UINT64(descriptorIncrementSize)
    }

    mutating func offset(_ offsetScaledByIncrementSize: Int) {
        handle.ptr += UInt64(offsetScaledByIncrementSize)
    }
}

extension D3D12_CPU_DESCRIPTOR_HANDLE: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ptr)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.ptr == rhs.ptr
    }
}
