enum SceneNodeDataType: Hashable {
    case any
    case anyElement
    case anyRaymarchingElement
    case geometry
    case raymarchingScene
    case color
    case materialMap
    case camera
    case vector3

    static func areAssignable(source: Self, target: Self) -> Bool {
        switch (source, target) {
        // General coercions
        case (let a, let b) where a == b:
            return true
        case (_, .any):
            return true

        // Custom coercions
        case (.geometry, .anyElement),
             (.geometry, .anyRaymarchingElement):
            return true
        case (.anyRaymarchingElement, .anyElement):
            return true
            
        default:
            return false
        }
    }
}

extension SceneNodeDataType: CustomStringConvertible {
    var description: String {
        switch self {
        case .any:
            return "Any"
        case .anyElement:
            return "Element"
        case .anyRaymarchingElement:
            return "Raymarching element"
        case .geometry:
            return "Geometry"
        case .raymarchingScene:
            return "Raymarching scene"
        case .color:
            return "Color"
        case .materialMap:
            return "Material map"
        case .camera:
            return "Camera"
        case .vector3:
            return "Vector3"
        }
    }
}

protocol SceneNodeDataTypeRepresentable {
    /// Gets the static data type for this scene node data representable type.
    static var staticDataType: SceneNodeDataType { get }

    /// Gets the dynamic data type for this scene node data type representable
    /// instance.
    ///
    /// Should be assignable to values of type `Self.staticDataType` via
    /// `SceneNodeDataType.areAssignable(source: self.dynamicDataType, target: Self.staticDataType)`
    var dynamicDataType: SceneNodeDataType { get }
}

extension SceneNodeDataTypeRepresentable {
    var dynamicDataType: SceneNodeDataType {
        Self.staticDataType
    }
}

extension AnyElement: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        return .anyElement
    }

    var dynamicDataType: SceneNodeDataType {
        if let representable = element as? SceneNodeDataTypeRepresentable {
            return representable.dynamicDataType
        }

        return .anyElement
    }
}

extension AnyRaymarchingElement: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        return .anyRaymarchingElement
    }

    var dynamicDataType: SceneNodeDataType { 
        if let representable = element as? SceneNodeDataTypeRepresentable {
            return representable.dynamicDataType
        }

        return .anyRaymarchingElement
    }
}

extension RVector3D: SceneNodeDataTypeRepresentable {
    static var staticDataType: SceneNodeDataType {
        .vector3
    }
}
