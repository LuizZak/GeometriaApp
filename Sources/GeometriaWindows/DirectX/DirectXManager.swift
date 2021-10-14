import WinSDK
import SwiftCOM
import MinWin32

private typealias Factory = DirectX.Infrastructure.Factory
private typealias Adapter = DirectX.Infrastructure.Adapter
private typealias SwapChain = DirectX.Infrastructure.SwapChain
private typealias Device = DirectX.Device
private typealias CommandQueue = DirectX.CommandQueue
private typealias InfoQueue = DirectX.InfoQueue
private typealias DescriptorHeap = DirectX.DescriptorHeap
private typealias Resource = DirectX.Resource
private typealias CommandAllocator = DirectX.CommandAllocator
private typealias Fence = DirectX.Fence
private typealias GraphicsCommandList = DirectX.GraphicsCommandList

class DirectXManager {
    #if DEBUG
    let debugMode: Bool = true
    #else
    let debugMode: Bool = false
    #endif
    
    private let useWarp: Bool = false

    private var state: DirectXState?

    init() {
    }

    deinit {
        // De-allocate resources
    }

    func initialize(window: Win32Window) throws {
        if debugMode {
            try enableDebugInterface()
        }

        let factory = try makeDxgiFactory()
        let adapter = try makeAdapter(factory)
        let device = try makeDevice(adapter)

        if debugMode {
            try enableDebugBreaks(device)
        }

        let backBufferCount = 3
        let queue = try makeCommandQueue(device)
        let swapChain = try makeSwapChain(factory, queue, window)
        let fence = try makeFence(device)
        let fenceEvent = try makeEventHandle()

        let fenceStructure = DirectXState.FenceStructure(
            fence: fence,
            fenceValue: 0,
            frameFenceValues: .init(repeating: 0, count: backBufferCount),
            fenceEvent: fenceEvent
        )

        state = .init(
            backBufferCount: backBufferCount,
            factory: factory,
            device: device,
            commandQueue: queue,
            swapChain: swapChain,
            fenceStructure: fenceStructure
        )
    }

    private func enableDebugInterface() throws {
        let debugInterface: DirectX.Debug = try D3D12GetDebugInterface()
        try debugInterface.EnableDebugLayer()
    }

    private func makeDxgiFactory() throws -> Factory {
        var flags: UINT = 0
        if debugMode {
            flags = UINT(DXGI_CREATE_FACTORY_DEBUG)
        }

        return try CreateDXGIFactory2(flags)
    }

    private func makeAdapter(_ factory: Factory) throws -> Adapter {
        if useWarp {
            return try factory.EnumWarpAdapter()
        }

        return try factory.EnumAdapterByGpuPreference(0, DXGI_GPU_PREFERENCE_HIGH_PERFORMANCE)
    }

    private func makeDevice(_ adapter: Adapter) throws -> Device {
        try D3D12CreateDevice(adapter, D3D_FEATURE_LEVEL_12_0)
    }

    private func enableDebugBreaks(_ device: Device) throws {
        let infoQueue: DirectX.InfoQueue = try device.QueryInterface()

        try infoQueue.SetBreakOnSeverity(D3D12_MESSAGE_SEVERITY_CORRUPTION, true)
        try infoQueue.SetBreakOnSeverity(D3D12_MESSAGE_SEVERITY_ERROR, true)
        try infoQueue.SetBreakOnSeverity(D3D12_MESSAGE_SEVERITY_WARNING, true)
    }

    private func makeCommandQueue(_ device: Device) throws -> CommandQueue {
        var desc = D3D12_COMMAND_QUEUE_DESC()
        desc.Type =     D3D12_COMMAND_LIST_TYPE_DIRECT
        desc.Priority = D3D12_COMMAND_QUEUE_PRIORITY_NORMAL.rawValue
        desc.Flags =    D3D12_COMMAND_QUEUE_FLAG_NONE
        desc.NodeMask = 0

        return try device.CreateCommandQueue(desc)
    }

    private func makeSwapChain(_ factory: Factory, _ queue: CommandQueue, _ window: Win32Window, bufferCount: Int = 2) throws -> SwapChain {
        var swapChainDesc = DXGI_SWAP_CHAIN_DESC1()
        swapChainDesc.Width = UINT(window.size.width)
        swapChainDesc.Height = UINT(window.size.height)
        swapChainDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM
        swapChainDesc.Stereo = false
        swapChainDesc.SampleDesc = .init(Count: 1, Quality: 0)
        swapChainDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT
        swapChainDesc.BufferCount = UINT(bufferCount)
        swapChainDesc.Scaling = DXGI_SCALING_STRETCH
        swapChainDesc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD
        swapChainDesc.AlphaMode = DXGI_ALPHA_MODE_UNSPECIFIED
        swapChainDesc.Flags = try checkTearingSupport(factory) ? UINT(DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING.rawValue) : 0

        return try factory.CreateSwapChainForHwnd(queue, window.hwnd, swapChainDesc, nil, nil)
    }

    private func checkTearingSupport(_ factory: Factory) throws -> Bool {
        var allowTearing: BOOL = 0
        allowTearing = try factory.CheckFeatureSupport(DXGI_FEATURE_PRESENT_ALLOW_TEARING)

        return allowTearing == 1
    }

    private func makeDescriptorHeap(_ device: Device, type: D3D12_DESCRIPTOR_HEAP_TYPE, numDescriptors: Int) throws -> DescriptorHeap {
        var desc = D3D12_DESCRIPTOR_HEAP_DESC()

        desc.NumDescriptors = UINT(numDescriptors)
        desc.Type = type

        return try device.CreateDescriptorHeap(desc)
    }
    
    private func makeCommandAllocator(_ device: Device, _ type: D3D12_COMMAND_LIST_TYPE) throws -> CommandAllocator {
        try device.CreateCommandAllocator(type)
    }

    private func makeCommandList(_ device: Device, _ commandAllocator: CommandAllocator, type: D3D12_COMMAND_LIST_TYPE) throws -> GraphicsCommandList {
        let commandList: GraphicsCommandList = try device.CreateCommandList(0, type, commandAllocator, nil)
        try commandList.Close()

        return commandList
    }

    private func makeFence(_ device: Device) throws -> Fence {
        try device.CreateFence(0, D3D12_FENCE_FLAG_NONE)
    }

    private func makeEventHandle() throws -> HANDLE {
        guard let event = CreateEventW(nil, false, false, nil) else {
            throw Error.failedToCreateEvent
        }
        
        return event
    }

    private enum Error: Swift.Error {
        case failedToCreateEvent
    }
}

private struct DirectXState {
    var backBufferCount: Int
    var backBufferIndex: Int = 0

    var factory: Factory
    var device: Device
    var commandQueue: CommandQueue
    var swapChain: SwapChain
    var backBuffers: [Resource] = []
    var commandAllocators: [CommandAllocator] = []
    var fenceStructure: FenceStructure

    mutating func updateRenderTargetViews(_ device: Device, _ swapChain: SwapChain, _ descriptorHeap: DescriptorHeap) throws {
        backBuffers.removeAll()

        let rtvDescriptorSize = try device.GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV);

        var rtvHandle = try CD3DX12_CPU_DESCRIPTOR_HANDLE(handle: descriptorHeap.GetCPUDescriptorHandleForHeapStart())

        for i in 0..<backBufferCount {
            let backBuffer: ID3D12Resource = try swapChain.GetBuffer(UINT(i))
    
            try device.CreateRenderTargetView(backBuffer, nil, rtvHandle.handle)

            backBuffers.append(backBuffer)
    
            rtvHandle.offset(Int(rtvDescriptorSize))
        }
    }

    struct FenceStructure {
        var fence: Fence
        var fenceValue: UInt64
        var frameFenceValues: [UInt64]
        var fenceEvent: HANDLE

        mutating func signal(commandQueue: CommandQueue) throws -> UInt64 {
            fenceValue &+= 1

            let fValue = fenceValue
            try commandQueue.Signal(fence, fValue)

            return fValue
        }

        func waitForFenceValue(fenceValue: UInt64, milliseconds: DWORD = .max) throws {
            guard try fence.GetCompletedValue() < fenceValue else {
                return
            }

            try fence.SetEventOnCompletion(fenceValue, fenceEvent)
            WaitForSingleObject(fenceEvent, milliseconds)
        }

        mutating func flush(_ commandQueue: CommandQueue) throws {
            let fenceValueForSignal = try signal(commandQueue: commandQueue)
            try waitForFenceValue(fenceValue: fenceValueForSignal)
        }
    }
}
