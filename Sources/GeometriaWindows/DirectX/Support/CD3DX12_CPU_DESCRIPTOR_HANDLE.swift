import WinSDK

typealias CD3DX12_CPU_DESCRIPTOR_HANDLE = D3D12_CPU_DESCRIPTOR_HANDLE

extension CD3DX12_CPU_DESCRIPTOR_HANDLE {
    init(_ other: D3D12_CPU_DESCRIPTOR_HANDLE, _ offsetInDescriptors: Int, _ descriptorIncrementSize: Int) {
        self.init(ptr: SIZE_T(INT64(other.ptr) + INT64(offsetInDescriptors) * INT64(descriptorIncrementSize)))
    }

    mutating func offset(_ offsetInDescriptors: Int, _ descriptorIncrementSize: Int) {
        ptr += UINT64(offsetInDescriptors) + UINT64(descriptorIncrementSize)
    }

    mutating func offset(_ offsetScaledByIncrementSize: Int) {
        ptr += UInt64(offsetScaledByIncrementSize)
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
