import SceneKit
extension SCNGeometrySource {
    convenience init(vertexCount: Int, vertexBuffer: MTLBuffer) {
        self.init(buffer: vertexBuffer, vertexFormat: .float3, semantic: .vertex, vertexCount: vertexCount, dataOffset: 0, dataStride: MemoryLayout<vector_float3>.size)
    }
    convenience init(normalCount: Int, normalBuffer: MTLBuffer) {
        self.init(buffer: normalBuffer, vertexFormat: .float3, semantic: .normal, vertexCount: normalCount, dataOffset: 0, dataStride: MemoryLayout<vector_float3>.size)
    }
    func process<A, B>(input: A.Type, output: B.Type, array: inout [B]) {
        self.data.withUnsafeBytes({ pointer in
            let address = pointer.baseAddress!
            let buffer = address.assumingMemoryBound(to: A.self)
            for vectorIndex in 0..<self.vectorCount {
                var vector = [A]()
                for componentIndex in 0..<self.componentsPerVector {
                    let index = vectorIndex * self.componentsPerVector + componentIndex
                    vector.append(buffer[index])
                }
                if ([A].self == B.self) {
                    array.append(vector as! B)
                } else if (A.self == B.self) {
                    array.append(contentsOf: vector as! [B])
                } else if (A.self is Float.Type && B.self is vector_float2.Type) {
                    array.append(vector_float2(vector as! [Float]) as! B)
                } else if (A.self is Float.Type && B.self is vector_float3.Type) {
                    array.append(vector_float3(vector as! [Float]) as! B)
                } else if (A.self is Float.Type && B.self is vector_float4.Type) {
                    array.append(vector_float4(vector as! [Float]) as! B)
                } else if (A.self is Int32.Type && B.self is [Int32].Type) {
                    array.append(vector as! B)
                } else if (A.self is Int16.Type && B.self is [Int32].Type) {
                    array.append(vector.map({ component in
                        return Int32(component as! Int16)
                    }) as! B)
                } else if (A.self is Int8.Type && B.self is [Int32].Type) {
                    array.append(vector.map({ component in
                        return Int32(component as! Int8)
                    }) as! B)
                } else {
                    fatalError()
                }
            }
        })
    }
}
