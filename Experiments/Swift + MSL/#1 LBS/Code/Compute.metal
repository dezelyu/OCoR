#include <metal_stdlib>
using namespace metal;
struct SkinningData {
    int32_t boneIndices[8];
    float boneWeights[8];
};
struct BoneData {
    float4x4 transformation;
};
#define COMPUTE_ARGUMENTS \
device float3* vertexInput [[buffer(0)]], \
device float3* normalInput [[buffer(1)]], \
device float3* vertexOutput [[buffer(2)]], \
device float3* normalOutput [[buffer(3)]], \
device SkinningData* skinningData [[buffer(4)]], \
device BoneData* boneData [[buffer(5)]], \
constant uint& count [[buffer(6)]], \
uint i [[thread_position_in_grid]]
kernel void Compute(COMPUTE_ARGUMENTS) {
    if (i < count) {
        vertexOutput[i] = vertexInput[i];
        normalOutput[i] = normalInput[i];
    }
}
