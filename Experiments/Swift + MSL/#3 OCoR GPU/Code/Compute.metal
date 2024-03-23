#include <metal_stdlib>
using namespace metal;
struct SkinningData {
    int32_t boneIndices[8];
    float boneWeights[8];
};
struct BoneData {
    float4x4 transformation;
    float2x4 dualQuaternion;
};
#define SKINNING_ARGUMENTS \
const float3 vertexInput, \
const float3 normalInput, \
const SkinningData skinningData, \
device BoneData* boneData, \
const float3 OCoR
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
float2x3 DQS(SKINNING_ARGUMENTS) {
    float2x4 dualQuaternion = float2x4(0.0f);
    for (int i = 0; i < 8; i += 1) {
        int boneIndex = skinningData.boneIndices[i];
        float boneWeight = skinningData.boneWeights[i];
        float2x4 boneDualQuaternion = boneData[boneIndex].dualQuaternion;
        if (dot(dualQuaternion[0], boneDualQuaternion[0]) < 0.0f) {
            boneWeight = -boneWeight;
        }
        dualQuaternion += boneDualQuaternion * boneWeight;
    }
    dualQuaternion = dualQuaternion / length(dualQuaternion[0]);
    float4 real = dualQuaternion[0];
    float4 dual = dualQuaternion[1];
    float4 conjugate = float4(-real.xyz, real.w);
    float4x4 transformation = float4x4(1.0f);
    transformation[0][0] = 1.0f - 2.0f * real.y * real.y - 2.0f * real.z * real.z;
    transformation[0][1] = 2.0f * real.x * real.y + 2.0f * real.w * real.z;
    transformation[0][2] = 2.0f * real.x * real.z - 2.0f * real.w * real.y;
    transformation[1][0] = 2.0f * real.x * real.y - 2.0f * real.w * real.z;
    transformation[1][1] = 1.0f - 2.0f * real.x * real.x - 2.0f * real.z * real.z;
    transformation[1][2] = 2.0f * real.y * real.z + 2.0f * real.w * real.x;
    transformation[2][0] = 2.0f * real.x * real.z + 2.0f * real.w * real.y;
    transformation[2][1] = 2.0f * real.y * real.z - 2.0f * real.w * real.x;
    transformation[2][2] = 1.0f - 2.0f * real.x * real.x - 2.0f * real.y * real.y;
    transformation[3].x = dot(dual.xyzw, conjugate.wzyx * float4(1.0f, 1.0f, -1.0f, 1.0f)) * 2.0f;
    transformation[3].y = dot(dual.xyzw, conjugate.zwxy * float4(-1.0f, 1.0f, 1.0f, 1.0f)) * 2.0f;
    transformation[3].z = dot(dual.xyzw, conjugate.yxwz * float4(1.0f, -1.0f, 1.0f, 1.0f)) * 2.0f;
    float2x3 output;
    output[0] = (transformation * float4(vertexInput, 1.0f)).xyz;
    output[1] = (transformation * float4(normalInput, 0.0f)).xyz;
    return output;
}
float2x3 OCoR(SKINNING_ARGUMENTS) {
    float4 quaternion = float4(0.0f);
    float4x4 transformation = float4x4(0.0f);
    for (int i = 0; i < 8; i += 1) {
        int boneIndex = skinningData.boneIndices[i];
        float boneWeight = skinningData.boneWeights[i];
        float4 boneQuaternion = boneData[boneIndex].dualQuaternion[0];
        float4x4 boneTransformation = boneData[boneIndex].transformation;
        if (dot(quaternion, boneQuaternion) < 0.0f) {
            quaternion -= boneQuaternion * boneWeight;
        } else {
            quaternion += boneQuaternion * boneWeight;
        }
        transformation += boneTransformation * boneWeight;
    }
    float4 real = normalize(quaternion);
    float3x3 rotation = float3x3(1.0f);
    rotation[0][0] = 1.0f - 2.0f * real.y * real.y - 2.0f * real.z * real.z;
    rotation[0][1] = 2.0f * real.x * real.y + 2.0f * real.w * real.z;
    rotation[0][2] = 2.0f * real.x * real.z - 2.0f * real.w * real.y;
    rotation[1][0] = 2.0f * real.x * real.y - 2.0f * real.w * real.z;
    rotation[1][1] = 1.0f - 2.0f * real.x * real.x - 2.0f * real.z * real.z;
    rotation[1][2] = 2.0f * real.y * real.z + 2.0f * real.w * real.x;
    rotation[2][0] = 2.0f * real.x * real.z + 2.0f * real.w * real.y;
    rotation[2][1] = 2.0f * real.y * real.z - 2.0f * real.w * real.x;
    rotation[2][2] = 1.0f - 2.0f * real.x * real.x - 2.0f * real.y * real.y;
    float4 translation = float4((transformation * float4(OCoR, 1.0f) - float4(rotation * OCoR, 0.0f)).xyz, 1.0f);
    transformation[0] = float4(rotation[0], 0.0f);
    transformation[1] = float4(rotation[1], 0.0f);
    transformation[2] = float4(rotation[2], 0.0f);
    transformation[3] = translation;
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
device float3* OCoRData [[buffer(6)]], \
constant uint& count [[buffer(7)]], \
uint i [[thread_position_in_grid]]
kernel void Compute(COMPUTE_ARGUMENTS) {
    if (i < count) {
        float2x3 outputOCoR = OCoR(vertexInput[i], normalInput[i], skinningData[i], boneData, OCoRData[i]);
        vertexOutput[i] = outputOCoR[0];
        normalOutput[i] = outputOCoR[1];
    }
}
