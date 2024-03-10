import SceneKit
class ModelNode: SCNNode {
    struct SkinningData {
        var boneIndices: vector_int8
        var boneWeights: vector_float8
    }
    var skinningData: [SkinningData]!
    var vertices: [vector_float3]!
    var normals: [vector_float3]!
    var indices: [UInt32]!
    var vertexInputBuffer: MTLBuffer!
    var normalInputBuffer: MTLBuffer!
    var vertexOutputBuffer: MTLBuffer!
    var normalOutputBuffer: MTLBuffer!
    var skinningDataBuffer: MTLBuffer!
    var meshNode: SCNNode!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init() {
        super.init()
        self.initializeMeshData()
        self.initializeMeshBuffers()
        self.initializeMeshNode()
    }
    func initializeMeshData() {
        var skinningData = [SkinningData]()
        var vertices = [vector_float3]()
        var normals = [vector_float3]()
        var indices = [UInt32]()
        let modelScene = SCNScene(named: "Assets.scnassets/Model.scn")!
        let meshNode = modelScene.rootNode.childNode(withName: "mesh", recursively: false)!
        let meshGeometry = meshNode.geometry!
        let skinner = meshNode.skinner!
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
        self.skinningData = skinningData
        self.vertices = vertices
        self.normals = normals
        self.indices = indices
    }
    func initializeMeshBuffers() {
        let device = MTLCreateSystemDefaultDevice()!
        let length = min(self.vertices.count, self.normals.count) * MemoryLayout<vector_float3>.size
        let skinningDataBufferLength = self.skinningData.count * MemoryLayout<ModelNode.SkinningData>.size
        let options = MTLResourceOptions.cpuCacheModeWriteCombined
        self.vertexInputBuffer = device.makeBuffer(bytes: self.vertices, length: length, options: options)!
        self.normalInputBuffer = device.makeBuffer(bytes: self.normals, length: length, options: options)!
        self.vertexOutputBuffer = device.makeBuffer(bytes: self.vertices, length: length, options: options)!
        self.normalOutputBuffer = device.makeBuffer(bytes: self.normals, length: length, options: options)!
        self.skinningDataBuffer = device.makeBuffer(bytes: self.skinningData, length: skinningDataBufferLength, options: options)!
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
}
