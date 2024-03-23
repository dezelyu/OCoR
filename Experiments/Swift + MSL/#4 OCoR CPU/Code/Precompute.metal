#include <metal_stdlib>
using namespace metal;
struct BoneWeightData {
    float weights[100];
};
struct TriangleData {
    float area;
    float3 center;
    BoneWeightData boneWeightData;
};
#define PRECOMPUTE_TRIANGLE_DATA_ARGUMENTS \
device uint* indexData [[buffer(0)]], \
device float3* vertexInput [[buffer(1)]], \
device BoneWeightData* boneWeightData [[buffer(2)]], \
device TriangleData* triangleData [[buffer(3)]], \
constant uint& count [[buffer(4)]], \
uint i [[thread_position_in_grid]]
kernel void PrecomputeTriangleData(PRECOMPUTE_TRIANGLE_DATA_ARGUMENTS) {
    if (i < count) {
        uint index0 = indexData[i * 3 + 0];
        uint index1 = indexData[i * 3 + 1];
        uint index2 = indexData[i * 3 + 2];
        float3 vertex0 = vertexInput[index0];
        float3 vertex1 = vertexInput[index1];
        float3 vertex2 = vertexInput[index2];
        float3 vector01 = vertex1 - vertex0;
        float3 vector02 = vertex2 - vertex0;
        float3 crossProduct = cross(vector01, vector02);
        float area = length(crossProduct) / 2.0f;
        float3 center = (vertex0 + vertex1 + vertex2) / 3.0f;
        triangleData[i].area = area;
        triangleData[i].center = center;
        for (int index = 0; index < 100; index += 1) {
            float weight0 = boneWeightData[index0].weights[index];
            float weight1 = boneWeightData[index1].weights[index];
            float weight2 = boneWeightData[index2].weights[index];
            float weight = (weight0 + weight1 + weight2) / 3.0f;
            triangleData[i].boneWeightData.weights[index] = weight;
        }
    }
}
#define PRECOMPUTE_OCOR_DATA_ARGUMENTS \
device BoneWeightData* boneWeightData [[buffer(0)]], \
device TriangleData* triangleData [[buffer(1)]], \
device float3* OCoRData [[buffer(2)]], \
constant uint& triangleCount [[buffer(3)]], \
constant uint& vertexCount [[buffer(4)]], \
uint i [[thread_position_in_grid]]
kernel void PrecomputeOCoRData(PRECOMPUTE_OCOR_DATA_ARGUMENTS) {
    if (i < vertexCount) {
        float3 numerator = float3(0.0f);
        float denominator = 0.0f;
        float sigma = 0.1f;
        float sigma2 = pow(sigma, 2.0f);
        for (uint index = 0; index < triangleCount; index += 1) {
            float similarity = 0.0f;
            device float* wp = boneWeightData[i].weights;
            device float* wv = triangleData[index].boneWeightData.weights;
            for (uint wpi = 0; wpi < 100; wpi += 1) {
                if (wp[wpi] > 0.0f && wv[wpi] > 0.0f) {
                    for (uint wvi = 0; wvi < 100; wvi += 1) {
                        if (wpi != wvi && wp[wvi] > 0.0f && wv[wvi] > 0.0f) {
                            float exponent = -pow(wp[wpi] * wv[wvi] - wp[wvi] * wv[wpi], 2.0f) / sigma2;
                            similarity += wp[wpi] * wp[wvi] * wv[wpi] * wv[wvi] * exp(exponent);
                        }
                    }
                }
            }
            numerator += similarity * triangleData[index].center * triangleData[index].area;
            denominator += similarity * triangleData[index].area;
        }
        if (denominator == 0.0f) {
            OCoRData[i] = float3(0.0f);
        } else {
            OCoRData[i] = numerator / denominator;
        }
    }
}
