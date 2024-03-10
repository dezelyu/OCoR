import SceneKit
extension SCNGeometryElement {
    func process(indices: inout [UInt32]) {
        if (self.primitiveType == .triangles) {
            self.data.withUnsafeBytes({ pointer in
                let address = pointer.baseAddress!
                if (self.bytesPerIndex == 4) {
                    let buffer = address.assumingMemoryBound(to: UInt32.self)
                    for primitiveIndex in 0..<self.primitiveCount {
                        indices.append(buffer[primitiveIndex * 3 + 0])
                        indices.append(buffer[primitiveIndex * 3 + 1])
                        indices.append(buffer[primitiveIndex * 3 + 2])
                    }
                } else if (self.bytesPerIndex == 2) {
                    let buffer = address.assumingMemoryBound(to: UInt16.self)
                    for primitiveIndex in 0..<self.primitiveCount {
                        indices.append(UInt32(buffer[primitiveIndex * 3 + 0]))
                        indices.append(UInt32(buffer[primitiveIndex * 3 + 1]))
                        indices.append(UInt32(buffer[primitiveIndex * 3 + 2]))
                    }
                } else if (self.bytesPerIndex == 1) {
                    let buffer = address.assumingMemoryBound(to: UInt8.self)
                    for primitiveIndex in 0..<self.primitiveCount {
                        indices.append(UInt32(buffer[primitiveIndex * 3 + 0]))
                        indices.append(UInt32(buffer[primitiveIndex * 3 + 1]))
                        indices.append(UInt32(buffer[primitiveIndex * 3 + 2]))
                    }
                }
            })
        } else {
            fatalError()
        }
    }
}
