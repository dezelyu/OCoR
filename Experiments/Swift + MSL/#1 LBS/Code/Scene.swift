import SceneKit
class Scene: SCNScene {
    var modelNode: SCNNode!
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
        let modelScene = SCNScene(named: "Assets.scnassets/Model.scn")!
        let modelNode = modelScene.rootNode.clone()
        let modelRoot = modelNode.childNode(withName: "root", recursively: false)!
        let animationScene = SCNScene(named: "Assets.scnassets/Animation.scn")!
        let animationRoot = animationScene.rootNode.childNode(withName: "root", recursively: false)!
        let animationKey = animationRoot.animationKeys.first!
        let animationPlayer = animationRoot.animationPlayer(forKey: animationKey)!
        modelRoot.addAnimationPlayer(animationPlayer, forKey: animationKey)
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
}
