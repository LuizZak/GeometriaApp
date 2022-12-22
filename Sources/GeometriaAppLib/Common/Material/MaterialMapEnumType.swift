public protocol MaterialMapEnumType: RawRepresentable where RawValue == MaterialId {
    func makeMaterial() -> Material
}

public func makeMaterialMap<T: CaseIterable & MaterialMapEnumType>(_ type: T.Type) -> MaterialMap {
    let allCases = type.allCases
    guard let maximum = allCases.map({ $0.rawValue }).max() else {
        return MaterialMap()
    }

    var map = MaterialMap(repeating: .default, count: maximum + 1)

    for material in type.allCases {
        assert(material.rawValue >= 0, "Materials cannot have negative indexes")
        map[material.rawValue] = material.makeMaterial()
    }

    return map
//    .init(uniqueKeysWithValues:
//        type.allCases.map {
//            ($0.rawValue, $0.makeMaterial())
//        }
//    )
}
