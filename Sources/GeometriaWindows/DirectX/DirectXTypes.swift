import SwiftCOM

typealias ID3D12Device = SwiftCOM.ID3D12Device
typealias IDXGIFactory6 = SwiftCOM.IDXGIFactory6
typealias IDXGIAdapter4 = SwiftCOM.IDXGIAdapter4
typealias ID3D12Debug = SwiftCOM.ID3D12Debug
typealias ID3D12CommandQueue = SwiftCOM.ID3D12CommandQueue
typealias ID3D12InfoQueue = SwiftCOM.ID3D12InfoQueue
typealias IDXGISwapChain1 = SwiftCOM.IDXGISwapChain1
typealias ID3D12DescriptorHeap = SwiftCOM.ID3D12DescriptorHeap
typealias ID3D12Resource = SwiftCOM.ID3D12Resource
typealias ID3D12CommandAllocator = SwiftCOM.ID3D12CommandAllocator
typealias ID3D12Fence = SwiftCOM.ID3D12Fence
typealias ID3D12GraphicsCommandList = SwiftCOM.ID3D12GraphicsCommandList

// Alias for Window's BOOL type
typealias BOOL = Int32

// MARK: Friendlier interfaces

public enum DirectX {
    public enum Infrastructure {
        typealias Factory = IDXGIFactory6
        typealias Adapter = IDXGIAdapter4
        typealias SwapChain = IDXGISwapChain1
    }

    typealias Device = ID3D12Device
    typealias Debug = ID3D12Debug
    typealias CommandQueue = ID3D12CommandQueue
    typealias InfoQueue = ID3D12InfoQueue
    typealias DescriptorHeap = ID3D12DescriptorHeap
    typealias Resource = ID3D12Resource
    typealias CommandAllocator = ID3D12CommandAllocator
    typealias Fence = ID3D12Fence
    typealias GraphicsCommandList = ID3D12GraphicsCommandList
}
