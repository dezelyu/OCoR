import SceneKit
class ModelNode: SCNNode {
    var vertices: [vector_float3]!
    var normals: [vector_float3]!
    var indices: [UInt32]!
    var meshNode: SCNNode!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init() {
        super.init()
        self.initializeMeshData()
        self.initializeMeshNode()
    }
    func initializeMeshData() {
        var vertices = [vector_float3]()
        var normals = [vector_float3]()
        var indices = [UInt32]()
        let modelScene = SCNScene(named: "Assets.scnassets/Model.scn")!
        let meshNode = modelScene.rootNode.childNode(withName: "mesh", recursively: false)!
        let meshGeometry = meshNode.geometry!
        for source in meshGeometry.sources {
            if (source.semantic == .vertex) {
                source.process(input: Float.self, output: vector_float3.self, array: &vertices)
            } else if (source.semantic == .normal) {
                source.process(input: Float.self, output: vector_float3.self, array: &normals)
            }
        }
        let meshElement = meshGeometry.elements.first!
        meshElement.process(indices: &indices)
        self.vertices = vertices
        self.normals = normals
        self.indices = indices
    }
    func initializeMeshNode() {
        let vertexSource = SCNGeometrySource(vertices: self.vertices.map({ vertex in return SCNVector3(vertex) }))
        let normalSource = SCNGeometrySource(normals: self.normals.map({ normal in return SCNVector3(normal) }))
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
