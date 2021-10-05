protocol MaterialMapType: RawRepresentable where RawValue == Int {
    func makeMaterial() -> Material
}

func makeMaterialMap<T: CaseIterable & MaterialMapType>(_ type: T.Type) -> [Int: Material] {
    .init(uniqueKeysWithValues:
        type.allCases.map {
            ($0.rawValue, $0.makeMaterial())
        }
    )
}
