import SwiftCOM

// Alias for Window's BOOL type
typealias BOOL = Int32

// MARK: Friendlier interfaces

public enum DirectX {
    public enum Infrastructure {
        typealias Factory = SwiftCOM.IDXGIFactory6
        typealias Adapter = SwiftCOM.IDXGIAdapter4
        typealias SwapChain = SwiftCOM.IDXGISwapChain3
        typealias Output = SwiftCOM.IDXGIOutput
    }

    typealias Device = SwiftCOM.ID3D12Device
    typealias Debug = SwiftCOM.ID3D12Debug
    typealias CommandQueue = SwiftCOM.ID3D12CommandQueue
    typealias InfoQueue = SwiftCOM.ID3D12InfoQueue
    typealias DescriptorHeap = SwiftCOM.ID3D12DescriptorHeap
    typealias Resource = SwiftCOM.ID3D12Resource
    typealias CommandAllocator = SwiftCOM.ID3D12CommandAllocator
    typealias Fence = SwiftCOM.ID3D12Fence
    typealias GraphicsCommandList = SwiftCOM.ID3D12GraphicsCommandList
}
