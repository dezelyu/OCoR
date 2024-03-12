import SceneKit
extension SCNSkinner {
    func process(influenceCount: Int, boneIndices: inout [[Int32]], boneWeights: inout [[Float]]) {
        let sameVectorCount = self.boneIndices.vectorCount == self.boneWeights.vectorCount
        let sameComponentCount = self.boneIndices.componentsPerVector == self.boneWeights.componentsPerVector
        if (!sameVectorCount || !sameComponentCount) {
            fatalError()
        }
        if (self.boneIndices.bytesPerComponent == 4) {
            self.boneIndices.process(input: Int32.self, output: [Int32].self, array: &boneIndices)
        } else if (self.boneIndices.bytesPerComponent == 2) {
            self.boneIndices.process(input: Int16.self, output: [Int32].self, array: &boneIndices)
        } else if (self.boneIndices.bytesPerComponent == 1) {
            self.boneIndices.process(input: Int8.self, output: [Int32].self, array: &boneIndices)
        }
        self.boneWeights.process(input: Float.self, output: [Float].self, array: &boneWeights)
        for vertexIndex in 0..<boneIndices.count {
            while (boneIndices[vertexIndex].count > influenceCount) {
                let index = boneWeights[vertexIndex].indices.min(by: { index0, index1 in
                    return boneWeights[vertexIndex][index0] < boneWeights[vertexIndex][index1]
                })!
                boneIndices[vertexIndex].remove(at: index)
                boneWeights[vertexIndex].remove(at: index)
            }
            let sum = boneWeights[vertexIndex].reduce(0.0, +)
            if (sum != 1.0 && sum > 0.0) {
                boneWeights[vertexIndex] = boneWeights[vertexIndex].map({ weight in
                    return weight / sum
                })
            }
            while (boneIndices[vertexIndex].count < influenceCount) {
                boneIndices[vertexIndex].append(0)
                boneWeights[vertexIndex].append(0.0)
            }
            if (boneWeights[vertexIndex] != boneWeights[vertexIndex].sorted(by: >)) {
                let array = zip(boneIndices[vertexIndex], boneWeights[vertexIndex])
                let sortedArray = array.sorted(by: { element0, element1 in
                    return element0.1 > element1.1
                })
                boneIndices[vertexIndex] = sortedArray.map({ element in
                    return element.0
                })
                boneWeights[vertexIndex] = sortedArray.map({ element in
                    return element.1
                })
            }
        }
    }
}
