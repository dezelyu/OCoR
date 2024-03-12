import SceneKit
class ModelNode: SCNNode {
    struct SkinningData {
        var boneIndices: vector_int8
        var boneWeights: vector_float8
    }
    struct BoneData {
        var transformation: matrix_float4x4
        var dualQuaternion: matrix_float2x4
    }
    var rootNode: SCNNode!
    var boneNodes: [SCNNode]!
    var bindMatrices: [SCNMatrix4]!
    var skinningData: [SkinningData]!
    var vertices: [vector_float3]!
    var normals: [vector_float3]!
    var indices: [UInt32]!
    var vertexInputBuffer: MTLBuffer!
    var normalInputBuffer: MTLBuffer!
    var vertexOutputBuffer: MTLBuffer!
    var normalOutputBuffer: MTLBuffer!
    var skinningDataBuffer: MTLBuffer!
    var boneDataBuffer: MTLBuffer!
    var meshNode: SCNNode!
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
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
    }
    func initializeMeshData() {
        var skinningData = [SkinningData]()
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
        self.vertices = vertices
        self.normals = normals
        self.indices = indices
    }
    func initializeMeshBuffers() {
        let device = MTLCreateSystemDefaultDevice()!
        let length = min(self.vertices.count, self.normals.count) * MemoryLayout<vector_float3>.size
        let skinningDataBufferLength = self.skinningData.count * MemoryLayout<ModelNode.SkinningData>.size
        let boneDataBufferLength = self.boneNodes.count * MemoryLayout<ModelNode.BoneData>.size
        let options = MTLResourceOptions.cpuCacheModeWriteCombined
        self.vertexInputBuffer = device.makeBuffer(bytes: self.vertices, length: length, options: options)!
        self.normalInputBuffer = device.makeBuffer(bytes: self.normals, length: length, options: options)!
        self.vertexOutputBuffer = device.makeBuffer(bytes: self.vertices, length: length, options: options)!
        self.normalOutputBuffer = device.makeBuffer(bytes: self.normals, length: length, options: options)!
        self.skinningDataBuffer = device.makeBuffer(bytes: self.skinningData, length: skinningDataBufferLength, options: options)!
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
        computeCommandEncoder.setBytes(&count, length: MemoryLayout<UInt32>.stride, index: 6)
        computeCommandEncoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadgroupSize)
        computeCommandEncoder.endEncoding()
        commandBuffer.commit()
    }
}
