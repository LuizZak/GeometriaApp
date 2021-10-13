import WinSDK
import SwiftCOM

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

    func initialize() throws {
        if debugMode {
            try enableDebugInterface()
        }

        let factory = try makeDxgiFactory()
        let adapter = try makeAdapter(factory)
        let device = try makeDevice(adapter)

        state = .init(factory: factory, device: device)
    }

    private func enableDebugInterface() throws {
        let debugInterface: ID3D12Debug = try D3D12GetDebugInterface()
        try debugInterface.EnableDebugLayer()
    }

    private func makeDxgiFactory() throws -> IDXGIFactory6 {
        var flags: UINT = 0
        if debugMode {
            flags = UINT(DXGI_CREATE_FACTORY_DEBUG)
        }

        return try CreateDXGIFactory2(flags)
    }

    private func makeAdapter(_ factory: IDXGIFactory6) throws -> IDXGIAdapter4 {
        if useWarp {
            return try factory.EnumWarpAdapter()
        }

        return try factory.EnumAdapterByGpuPreference(0, DXGI_GPU_PREFERENCE_HIGH_PERFORMANCE)
    }

    private func makeDevice(_ adapter: IDXGIAdapter4) throws -> ID3D12Device {
        try D3D12CreateDevice(adapter, D3D_FEATURE_LEVEL_12_0)
    }
}

private struct DirectXState {
    var factory: IDXGIFactory6
    var device: ID3D12Device
}
