import SceneKit
extension SCNMatrix4 {
    var quaternion: vector_float4 {
        var quaternion = vector_float4()
        let matrix = matrix_float4x4(self)
        quaternion.x = sqrt((1.0 + matrix[0][0] - matrix[1][1] - matrix[2][2]) * 0.25);
        quaternion.y = sqrt((1.0 - matrix[0][0] + matrix[1][1] - matrix[2][2]) * 0.25);
        quaternion.z = sqrt((1.0 - matrix[0][0] - matrix[1][1] + matrix[2][2]) * 0.25);
        quaternion.w = sqrt((1.0 + matrix[0][0] + matrix[1][1] + matrix[2][2]) * 0.25);
        if (quaternion.x.isNaN) {
            quaternion.x = -Float.greatestFiniteMagnitude
        } else if (quaternion.y.isNaN) {
            quaternion.y = -Float.greatestFiniteMagnitude
        } else if (quaternion.z.isNaN) {
            quaternion.z = -Float.greatestFiniteMagnitude
        } else if (quaternion.w.isNaN) {
            quaternion.w = -Float.greatestFiniteMagnitude
        }
        let max = max(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
        if (max == quaternion.w) {
            quaternion.x = (matrix[2][1] - matrix[1][2]) / (quaternion.w * 4.0);
            quaternion.y = (matrix[0][2] - matrix[2][0]) / (quaternion.w * 4.0);
            quaternion.z = (matrix[1][0] - matrix[0][1]) / (quaternion.w * 4.0);
        } else if (max == quaternion.x) {
            quaternion.w = (matrix[2][1] - matrix[1][2]) / (quaternion.x * 4.0);
            quaternion.y = (matrix[0][1] + matrix[1][0]) / (quaternion.x * 4.0);
            quaternion.z = (matrix[0][2] + matrix[2][0]) / (quaternion.x * 4.0);
        } else if (max == quaternion.y) {
            quaternion.w = (matrix[0][2] - matrix[2][0]) / (quaternion.y * 4.0);
            quaternion.x = (matrix[0][1] + matrix[1][0]) / (quaternion.y * 4.0);
            quaternion.z = (matrix[1][2] + matrix[2][1]) / (quaternion.y * 4.0);
        } else if (max == quaternion.z) {
            quaternion.w = (matrix[1][0] - matrix[0][1]) / (quaternion.z * 4.0);
            quaternion.x = (matrix[0][2] + matrix[2][0]) / (quaternion.z * 4.0);
            quaternion.y = (matrix[1][2] + matrix[2][1]) / (quaternion.z * 4.0);
        }
        return normalize(quaternion)
    }
    var dualQuaternion: matrix_float2x4 {
        let matrix = matrix_float4x4(self)
        let quaternion = self.quaternion
        var translation = matrix_float4x3()
        translation[0] = vector_float3(x: matrix[3][0], y: matrix[3][1], z: -matrix[3][2])
        translation[1] = vector_float3(x: -matrix[3][0], y: matrix[3][1], z: matrix[3][2])
        translation[2] = vector_float3(x: matrix[3][0], y: -matrix[3][1], z: matrix[3][2])
        translation[3] = vector_float3(x: -matrix[3][0], y: -matrix[3][1], z: -matrix[3][2])
        let real = vector_float4(x: -quaternion.x, y: -quaternion.y, z: -quaternion.z, w: quaternion.w)
        var dual = vector_float4()
        dual.x = (translation[0].x * real.w + translation[0].y * real.z + translation[0].z * real.y) * 0.5
        dual.y = (translation[1].x * real.z + translation[1].y * real.w + translation[1].z * real.x) * 0.5
        dual.z = (translation[2].x * real.y + translation[2].y * real.x + translation[2].z * real.w) * 0.5
        dual.w = (translation[3].x * real.x + translation[3].y * real.y + translation[3].z * real.z) * 0.5
        return matrix_float2x4(real, dual)
    }
}
