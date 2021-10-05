protocol MaterialMapEnumType: RawRepresentable where RawValue == MaterialId {
    func makeMaterial() -> Material
}

func makeMaterialMap<T: CaseIterable & MaterialMapEnumType>(_ type: T.Type) -> MaterialMap {
    type.allCases.map { $0.makeMaterial() }
//    .init(uniqueKeysWithValues:
//        type.allCases.map {
//            ($0.rawValue, $0.makeMaterial())
//        }
//    )
}
