#include <metal_stdlib>
using namespace metal;
struct SkinningData {
    int32_t boneIndices[8];
    float boneWeights[8];
};
struct BoneData {
    float4x4 transformation;
};
#define SKINNING_ARGUMENTS \
const float3 vertexInput, \
const float3 normalInput, \
const SkinningData skinningData, \
device BoneData* boneData
float2x3 LBS(SKINNING_ARGUMENTS) {
    float4x4 transformation = float4x4(0.0f);
    for (int i = 0; i < 8; i += 1) {
        int boneIndex = skinningData.boneIndices[i];
        float boneWeight = skinningData.boneWeights[i];
        transformation += boneData[boneIndex].transformation * boneWeight;
    }
    float2x3 output;
    output[0] = (transformation * float4(vertexInput, 1.0f)).xyz;
    output[1] = (transformation * float4(normalInput, 0.0f)).xyz;
    return output;
}
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
        float2x3 outputLBS = LBS(vertexInput[i], normalInput[i], skinningData[i], boneData);
        vertexOutput[i] = outputLBS[0];
        normalOutput[i] = outputLBS[1];
    }
}
