#include <maya/MFnPlugin.h>
#include <maya/MPxSkinCluster.h>
#include <maya/MFnMatrixData.h>
#include <maya/MItGeometry.h>
#include <maya/MMatrix.h>
#include <maya/MPoint.h>
class node final : public MPxSkinCluster {
public:
    inline static const MTypeId id {0xDEADC0DE};
    inline static void* creator() {
        return new node();
    }
    inline static MStatus initialize() {
        return MStatus::kSuccess;
    }
    inline MStatus deform(MDataBlock& block, MItGeometry& iterator, const MMatrix& matrix, unsigned int index) override {
        MArrayDataHandle matrix_handle {block.inputArrayValue(node::matrix)};
        MArrayDataHandle weight_list_handle {block.inputArrayValue(node::weightList)};
        MArrayDataHandle bind_pre_matrix_handle {block.inputArrayValue(node::bindPreMatrix)};
        if (matrix_handle.elementCount() == 0 || weight_list_handle.elementCount() == 0 || bind_pre_matrix_handle.elementCount() == 0) {
            return MStatus::kSuccess;
        }
        MMatrix matrix_inverse {matrix.inverse()};
        for (iterator.reset(); !iterator.isDone(); iterator.next()) {
            MPoint input_position {iterator.position() * matrix};
            MPoint output_position {};
            MArrayDataHandle weights_handle {weight_list_handle.inputValue().child(weights)};
            for (unsigned int i {0}; i < weights_handle.elementCount(); i += 1) {
                unsigned int joint_index {weights_handle.elementIndex()};
                matrix_handle.jumpToElement(joint_index);
                bind_pre_matrix_handle.jumpToElement(joint_index);
                weights_handle.jumpToArrayElement(i);
                MMatrix matrix {MFnMatrixData(matrix_handle.inputValue().data()).matrix()};
                MMatrix bind_pre_matrix {MFnMatrixData(bind_pre_matrix_handle.inputValue().data()).matrix()};
                double weight {weights_handle.inputValue().asDouble()};
                output_position += input_position * bind_pre_matrix * matrix * weight;
            }
            iterator.setPosition(output_position * matrix_inverse);
            weight_list_handle.next();
        }
        return MStatus::kSuccess;
    }
};
MStatus initializePlugin(MObject object) {
    MFnPlugin plugin {object};
    return plugin.registerNode("LBSNode", node::id, &node::creator, &node::initialize, MPxNode::kSkinCluster);
}
MStatus uninitializePlugin(MObject object) {
    MFnPlugin plugin {object};
    return plugin.deregisterNode(node::id);
}
