import SceneKit
class ModelNode: SCNNode {
    struct SkinningData {
        var boneIndices: vector_int8
        var boneWeights: vector_float8
    }
    struct BoneWeightData {
        var weights: (
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float,
            Float, Float, Float, Float, Float
        )
    }
    struct TriangleData {
        var area: Float
        var center: vector_float3
        var boneWeightData: BoneWeightData
    }
    struct BoneData {
        var transformation: matrix_float4x4
        var dualQuaternion: matrix_float2x4
    }
    var rootNode: SCNNode!
    var boneNodes: [SCNNode]!
    var bindMatrices: [SCNMatrix4]!
    var skinningData: [SkinningData]!
    var boneWeightData: [BoneWeightData]!
    var boneWeightArrayData: [[Float]]!
    var vertices: [vector_float3]!
    var normals: [vector_float3]!
    var indices: [UInt32]!
    var vertexInputBuffer: MTLBuffer!
    var normalInputBuffer: MTLBuffer!
    var vertexOutputBuffer: MTLBuffer!
    var normalOutputBuffer: MTLBuffer!
    var skinningDataBuffer: MTLBuffer!
    var boneWeightDataBuffer: MTLBuffer!
    var triangleDataBuffer: MTLBuffer!
    var indexDataBuffer: MTLBuffer!
    var OCoRDataBuffer: MTLBuffer!
    var boneDataBuffer: MTLBuffer!
    var meshNode: SCNNode!
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
    var precomputeTriangleDataPipelineState: MTLComputePipelineState!
    var precomputeOCoRDataPipelineState: MTLComputePipelineState!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init() {
        super.init()
        self.initializeMeshData()
        self.initializeMeshBuffers()
        self.initializeMeshNode()
        self.initializeAnimation()
        self.initializeComputePipeline()
        self.initializePrecomputePipelines()
        self.precomputeTriangleData()
        self.precomputeOCoRData()
    }
    func initializeMeshData() {
        var skinningData = [SkinningData]()
        var boneWeightData = [BoneWeightData]()
        var boneWeightArrayData = [[Float]]()
        var vertices = [vector_float3]()
        var normals = [vector_float3]()
        var indices = [UInt32]()
        let modelScene = SCNScene(named: "Assets.scnassets/Model.scn")!
        let rootNode = modelScene.rootNode.childNode(withName: "root", recursively: false)!
        let meshNode = modelScene.rootNode.childNode(withName: "mesh", recursively: false)!
        let meshGeometry = meshNode.geometry!
        let skinner = meshNode.skinner!
        var boneNodes = [SCNNode]()
        var bindMatrices = [SCNMatrix4]()
        for boneNode in skinner.bones {
            boneNodes.append(boneNode)
            bindMatrices.append(SCNMatrix4Invert(boneNode.worldTransform))
        }
        var skinnerBoneIndices = [[Int32]]()
        var skinnerBoneWeights = [[Float]]()
        skinner.process(influenceCount: 8, boneIndices: &skinnerBoneIndices, boneWeights: &skinnerBoneWeights)
        for vertexIndex in 0..<skinnerBoneIndices.count {
            let boneIndices = vector_int8(skinnerBoneIndices[vertexIndex])
            let boneWeights = vector_float8(skinnerBoneWeights[vertexIndex])
            skinningData.append(SkinningData(boneIndices: boneIndices, boneWeights: boneWeights))
            let weight = Float(0.0)
            var weights = (
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight,
                weight, weight, weight, weight, weight
            )
            Swift.withUnsafeMutableBytes(of: &weights, { pointer in
                let address = pointer.baseAddress!
                let buffer = address.assumingMemoryBound(to: Float.self)
                for index in 0..<8 {
                    let boneIndex = Int(skinnerBoneIndices[vertexIndex][index])
                    let boneWeight = skinnerBoneWeights[vertexIndex][index]
                    if (boneWeight > 0.0) {
                        buffer[boneIndex] = boneWeight
                    }
                }
            })
            boneWeightData.append(BoneWeightData(weights: weights))
            var boneWeightArray = [Float](repeating: 0.0, count: 100)
            for index in 0..<8 {
                let boneIndex = Int(skinnerBoneIndices[vertexIndex][index])
                let boneWeight = skinnerBoneWeights[vertexIndex][index]
                if (boneWeight > 0.0) {
                    boneWeightArray[boneIndex] = boneWeight
                }
            }
            boneWeightArrayData.append(boneWeightArray)
        }
        for source in meshGeometry.sources {
            if (source.semantic == .vertex) {
                source.process(input: Float.self, output: vector_float3.self, array: &vertices)
            } else if (source.semantic == .normal) {
                source.process(input: Float.self, output: vector_float3.self, array: &normals)
            }
        }
        let meshElement = meshGeometry.elements.first!
        meshElement.process(indices: &indices)
        rootNode.removeFromParentNode()
        self.addChildNode(rootNode)
        self.rootNode = rootNode
        self.boneNodes = boneNodes
        self.bindMatrices = bindMatrices
        self.skinningData = skinningData
        self.boneWeightData = boneWeightData
        self.boneWeightArrayData = boneWeightArrayData
        self.vertices = vertices
        self.normals = normals
        self.indices = indices
    }
    func initializeMeshBuffers() {
        let device = MTLCreateSystemDefaultDevice()!
        let length = min(self.vertices.count, self.normals.count) * MemoryLayout<vector_float3>.size
        let skinningDataBufferLength = self.skinningData.count * MemoryLayout<ModelNode.SkinningData>.size
        let boneWeightDataBufferLength = self.boneWeightData.count * MemoryLayout<ModelNode.BoneWeightData>.size
        let triangleDataBufferLength = (self.indices.count / 3) * MemoryLayout<ModelNode.TriangleData>.size
        let indexDataBufferLength = self.indices.count * MemoryLayout<UInt32>.size
        let boneDataBufferLength = self.boneNodes.count * MemoryLayout<ModelNode.BoneData>.size
        let options = MTLResourceOptions.cpuCacheModeWriteCombined
        self.vertexInputBuffer = device.makeBuffer(bytes: self.vertices, length: length, options: options)!
        self.normalInputBuffer = device.makeBuffer(bytes: self.normals, length: length, options: options)!
        self.vertexOutputBuffer = device.makeBuffer(bytes: self.vertices, length: length, options: options)!
        self.normalOutputBuffer = device.makeBuffer(bytes: self.normals, length: length, options: options)!
        self.skinningDataBuffer = device.makeBuffer(bytes: self.skinningData, length: skinningDataBufferLength, options: options)!
        self.boneWeightDataBuffer = device.makeBuffer(bytes: self.boneWeightData, length: boneWeightDataBufferLength, options: options)!
        self.triangleDataBuffer = device.makeBuffer(length: triangleDataBufferLength, options: options)!
        self.indexDataBuffer = device.makeBuffer(bytes: self.indices, length: indexDataBufferLength, options: options)!
        self.OCoRDataBuffer = device.makeBuffer(length: length, options: options)!
        self.boneDataBuffer = device.makeBuffer(length: boneDataBufferLength, options: options)!
    }
    func initializeMeshNode() {
        let vertexSource = SCNGeometrySource(vertexCount: self.vertices.count, vertexBuffer: self.vertexOutputBuffer)
        let normalSource = SCNGeometrySource(normalCount: self.normals.count, normalBuffer: self.normalOutputBuffer)
        let element = SCNGeometryElement(indices: self.indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.0
        material.roughness.contents = 0.5
        material.diffuse.contents = NSColor(white: 0.5, alpha: 1.0)
        material.isLitPerPixel = true
        material.isDoubleSided = true
        material.blendMode = .replace
        geometry.materials = [material]
        let modelNode = SCNNode(geometry: geometry)
        self.addChildNode(modelNode)
        self.meshNode = modelNode
    }
    func initializeAnimation() {
        let animationScene = SCNScene(named: "Assets.scnassets/Animation.scn")!
        let animationRoot = animationScene.rootNode.childNode(withName: "root", recursively: false)!
        let animationKey = animationRoot.animationKeys.first!
        let animationPlayer = animationRoot.animationPlayer(forKey: animationKey)!
        self.rootNode.addAnimationPlayer(animationPlayer, forKey: "Animation")
    }
    func initializeComputePipeline() {
        let device = MTLCreateSystemDefaultDevice()!
        let library = device.makeDefaultLibrary()!
        let function = library.makeFunction(name: "Compute")!
        self.commandQueue = device.makeCommandQueue()!
        self.computePipelineState = try! device.makeComputePipelineState(function: function)
    }
    func initializePrecomputePipelines() {
        let device = MTLCreateSystemDefaultDevice()!
        let library = device.makeDefaultLibrary()!
        let precomputeTriangleDataFunction = library.makeFunction(name: "PrecomputeTriangleData")!
        let precomputeOCoRDataFunction = library.makeFunction(name: "PrecomputeOCoRData")!
        self.precomputeTriangleDataPipelineState = try! device.makeComputePipelineState(function: precomputeTriangleDataFunction)
        self.precomputeOCoRDataPipelineState = try! device.makeComputePipelineState(function: precomputeOCoRDataFunction)
    }
    func updateBoneData() {
        let buffer = self.boneDataBuffer.contents().bindMemory(to: ModelNode.BoneData.self, capacity: self.boneNodes.count)
        for boneIndex in 0..<self.boneNodes.count {
            let boneNode = self.boneNodes[boneIndex]
            let bindMatrix = self.bindMatrices[boneIndex]
            let boneMatrix = boneNode.presentation.worldTransform
            let transformation = matrix_float4x4(SCNMatrix4Mult(bindMatrix, boneMatrix))
            let dualQuaternion = SCNMatrix4(transformation).dualQuaternion
            let boneData = BoneData(transformation: transformation, dualQuaternion: dualQuaternion)
            let pointer = buffer + boneIndex
            pointer.pointee = boneData
        }
    }
    func compute() {
        let commandBuffer = self.commandQueue.makeCommandBuffer()!
        var count = UInt32(self.vertices.count)
        let gridSize = MTLSize(width: self.vertices.count / self.computePipelineState.threadExecutionWidth + 1, height: 1, depth: 1)
        let threadgroupSize = MTLSize(width: self.computePipelineState.threadExecutionWidth, height: 1, depth: 1)
        let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeCommandEncoder.setComputePipelineState(self.computePipelineState)
        computeCommandEncoder.setBuffer(self.vertexInputBuffer, offset: 0, index: 0)
        computeCommandEncoder.setBuffer(self.normalInputBuffer, offset: 0, index: 1)
        computeCommandEncoder.setBuffer(self.vertexOutputBuffer, offset: 0, index: 2)
        computeCommandEncoder.setBuffer(self.normalOutputBuffer, offset: 0, index: 3)
        computeCommandEncoder.setBuffer(self.skinningDataBuffer, offset: 0, index: 4)
        computeCommandEncoder.setBuffer(self.boneDataBuffer, offset: 0, index: 5)
        computeCommandEncoder.setBuffer(self.OCoRDataBuffer, offset: 0, index: 6)
        computeCommandEncoder.setBytes(&count, length: MemoryLayout<UInt32>.stride, index: 7)
        computeCommandEncoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadgroupSize)
        computeCommandEncoder.endEncoding()
        commandBuffer.commit()
    }
    func precomputeTriangleData() {
        let commandBuffer = self.commandQueue.makeCommandBuffer()!
        var count = UInt32(self.indices.count / 3)
        let gridSize = MTLSize(width: (self.indices.count / 3) / self.precomputeTriangleDataPipelineState.threadExecutionWidth + 1, height: 1, depth: 1)
        let threadgroupSize = MTLSize(width: self.precomputeTriangleDataPipelineState.threadExecutionWidth, height: 1, depth: 1)
        let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeCommandEncoder.setComputePipelineState(self.precomputeTriangleDataPipelineState)
        computeCommandEncoder.setBuffer(self.indexDataBuffer, offset: 0, index: 0)
        computeCommandEncoder.setBuffer(self.vertexInputBuffer, offset: 0, index: 1)
        computeCommandEncoder.setBuffer(self.boneWeightDataBuffer, offset: 0, index: 2)
        computeCommandEncoder.setBuffer(self.triangleDataBuffer, offset: 0, index: 3)
        computeCommandEncoder.setBytes(&count, length: MemoryLayout<UInt32>.stride, index: 4)
        computeCommandEncoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadgroupSize)
        computeCommandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    func precomputeOCoRData() {
        let commandBuffer = self.commandQueue.makeCommandBuffer()!
        var triangleCount = UInt32(self.indices.count / 3)
        var vertexCount = UInt32(self.vertices.count)
        let gridSize = MTLSize(width: self.vertices.count / self.precomputeOCoRDataPipelineState.threadExecutionWidth + 1, height: 1, depth: 1)
        let threadgroupSize = MTLSize(width: self.precomputeOCoRDataPipelineState.threadExecutionWidth, height: 1, depth: 1)
        let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeCommandEncoder.setComputePipelineState(self.precomputeOCoRDataPipelineState)
        computeCommandEncoder.setBuffer(self.boneWeightDataBuffer, offset: 0, index: 0)
        computeCommandEncoder.setBuffer(self.triangleDataBuffer, offset: 0, index: 1)
        computeCommandEncoder.setBuffer(self.OCoRDataBuffer, offset: 0, index: 2)
        computeCommandEncoder.setBytes(&triangleCount, length: MemoryLayout<UInt32>.stride, index: 3)
        computeCommandEncoder.setBytes(&vertexCount, length: MemoryLayout<UInt32>.stride, index: 4)
        computeCommandEncoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadgroupSize)
        computeCommandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
