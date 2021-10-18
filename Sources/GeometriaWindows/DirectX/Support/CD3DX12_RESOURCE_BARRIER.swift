import WinSDK
import SwiftCOM

typealias CD3DX12_RESOURCE_BARRIER = D3D12_RESOURCE_BARRIER

extension CD3DX12_RESOURCE_BARRIER {
    static func transition(_ pResource: DirectX.Resource,
                           _ stateBefore: D3D12_RESOURCE_STATES,
                           _ stateAfter: D3D12_RESOURCE_STATES,
                           _ subresource: UINT = UINT(D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES),
                           _ flags: D3D12_RESOURCE_BARRIER_FLAGS = D3D12_RESOURCE_BARRIER_FLAG_NONE) -> Self {
        
        var result = CD3DX12_RESOURCE_BARRIER()
        result.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION
        result.Flags = flags
        result.Transition.pResource = RawPointer(pResource)
        result.Transition.StateBefore = stateBefore
        result.Transition.StateAfter = stateAfter
        result.Transition.Subresource = subresource

        assert(result.Transition.pResource != nil, "result.Transition.pResource")

        return result
    }

    /* TODO: Consider implementing the following methods:
    static inline CD3DX12_RESOURCE_BARRIER Aliasing(
        _In_ ID3D12Resource* pResourceBefore,
        _In_ ID3D12Resource* pResourceAfter)
    {
        CD3DX12_RESOURCE_BARRIER result = {};
        D3D12_RESOURCE_BARRIER &barrier = result;
        result.Type = D3D12_RESOURCE_BARRIER_TYPE_ALIASING;
        barrier.Aliasing.pResourceBefore = pResourceBefore;
        barrier.Aliasing.pResourceAfter = pResourceAfter;
        return result;
    }
    static inline CD3DX12_RESOURCE_BARRIER UAV(
        _In_ ID3D12Resource* pResource)
    {
        CD3DX12_RESOURCE_BARRIER result = {};
        D3D12_RESOURCE_BARRIER &barrier = result;
        result.Type = D3D12_RESOURCE_BARRIER_TYPE_UAV;
        barrier.UAV.pResource = pResource;
        return result;
    }
    */
}
