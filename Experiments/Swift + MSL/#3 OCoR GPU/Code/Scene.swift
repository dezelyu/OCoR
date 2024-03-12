import SceneKit
class Scene: SCNScene {
    var modelNode: ModelNode!
    var cameraNode: SCNNode!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init() {
        super.init()
        self.initializeModelNode()
        self.initializeCameraNode()
    }
    func initializeModelNode() {
        let modelNode = ModelNode()
        self.rootNode.addChildNode(modelNode)
        self.modelNode = modelNode
    }
    func initializeCameraNode() {
        let camera = SCNCamera()
        camera.fieldOfView = 60.0
        camera.zNear = 0.1
        camera.zFar = 1000.0
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: -150.0, y: 90.0, z: 150.0)
        cameraNode.eulerAngles.y = -45.0 * CGFloat.pi / 180.0
        self.rootNode.addChildNode(cameraNode)
        self.cameraNode = cameraNode
    }
    func rendererDidApplyAnimations() {
        self.modelNode.updateBoneData()
    }
    func rendererWillRenderScene() {
        self.modelNode.compute()
    }
}
