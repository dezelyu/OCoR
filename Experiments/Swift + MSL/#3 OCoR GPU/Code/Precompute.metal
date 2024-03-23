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
uint i [[thread_position_in_grid]]
kernel void PrecomputeTriangleData(PRECOMPUTE_TRIANGLE_DATA_ARGUMENTS) {
}
#define PRECOMPUTE_OCOR_DATA_ARGUMENTS \
uint i [[thread_position_in_grid]]
kernel void PrecomputeOCoRData(PRECOMPUTE_OCOR_DATA_ARGUMENTS) {
}
