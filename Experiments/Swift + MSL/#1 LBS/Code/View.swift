import SceneKit
class View: SCNView, SCNSceneRendererDelegate {
    func load() {
        let scene = Scene()
        self.pointOfView = scene.cameraNode
        self.scene = scene
        self.delegate = self
        self.allowsCameraControl = true
        self.isJitteringEnabled = true
        self.antialiasingMode = .multisampling4X
        self.autoenablesDefaultLighting = true
        self.showsStatistics = true
        self.debugOptions = []
        self.isPlaying = true
        self.loops = true
    }
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        let scene = self.scene as! Scene
        scene.rendererDidApplyAnimations()
    }
}
