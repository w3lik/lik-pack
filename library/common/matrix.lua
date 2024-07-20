---@class matrix 矩阵
matrix = matrix or {}

matrix._preTransforms = {
    ["4x4"] = {
        { 1, 0, 0, 1 },
        { 0, 1, -1, 0 },
        { -1, 0, 0, -1 },
        { 0, -1, 1, 0 }
    }
}

--- 乘
---@param a number[][]
---@param b number[][]
---@return number[][]
function matrix.multiply(a, b)
    local new = {}
    local m = #a
    local n = #(a[1])
    for i = 1, m do
        new[i] = {}
        for j = 1, n do
            local val = 0
            for k = 1, n do
                val = val + b[i][k] * a[k][j]
            end
            new[i][j] = val
        end
    end
    return new
end

--- 4x4 透视投影
---@param fov number FOV视野弧度
---@param aspect number 纵横比
---@param near number 近深度剪裁平面
---@param far number 远深度剪裁平面
---@param isFOV_Y boolean 是否Y型FOV
---@param minClipZ number 最小夹角Z
---@param projectionSignY number 投影Y
---@param orientation number 定向轴
---@return number[][]
function matrix.perspective44(fov, aspect, near, far, isFOV_Y, minClipZ, projectionSignY, orientation)
    local f = 1.0 / math.tan(fov / 2)
    local nf = 1 / (near - far)
    local x = isFOV_Y and f / aspect or f
    local y = (isFOV_Y and f or f * aspect) * projectionSignY
    local ptf = matrix._preTransforms["4x4"][orientation]
    return {
        { x * ptf[1], x * ptf[2], 0, 0 },
        { y * ptf[3], y * ptf[4], 0, 0 },
        { 0, 0, (far - minClipZ * near) * nf, -1 },
        { 0, 0, far * near * nf * (1 - minClipZ), 0 },
    }
end

--- 4x4 平行投影
---@param left number 左
---@param right number 右
---@param bottom number 底
---@param top number 顶
---@param near number 近深度剪裁平面
---@param far number 远深度剪裁平面
---@param minClipZ number 最小夹角Z
---@param projectionSignY number 投影Y
---@param orientation number 定向轴
---@return number[][]
function matrix.ortho44(left, right, bottom, top, near, far, minClipZ, projectionSignY, orientation)
    local lr = 1 / (left - right)
    local bt = 1 / (bottom - top) * projectionSignY
    local nf = 1 / (near - far)
    local x = -2 * lr
    local y = -2 * bt
    local dx = (left + right) * lr
    local dy = (top + bottom) * bt
    local ptf = matrix._preTransforms["4x4"][orientation]
    return {
        { x * ptf[1], x * ptf[2], 0, 0 },
        { y * ptf[3], y * ptf[4], 0, 0 },
        { 0, 0, nf * (1 - minClipZ), 0 },
        { dx * ptf[1] + dy * ptf[3], dx * ptf[2] + dy * ptf[4], (near - minClipZ * far) * nf, 1 },
    }
end

--- 4x4 视线
---@param eye number[3] 眼轴
---@param center number[3] 中心轴
---@param up number[3] 上轴
---@return number[][]
function matrix.lookAt44(eye, center, up)
    local eyeX = eye[1]
    local eyeY = eye[2]
    local eyeZ = eye[3]
    local upX = up[1]
    local upY = up[2]
    local upZ = up[3]
    local centerX = center[1]
    local centerY = center[2]
    local centerZ = center[3]
    local z0 = eyeX - centerX
    local z1 = eyeY - centerY
    local z2 = eyeZ - centerZ
    local len = 1 / math.sqrt(z0 * z0 + z1 * z1 + z2 * z2)
    z0 = z0 * len
    z1 = z1 * len
    z2 = z2 * len
    local x0 = upY * z2 - upZ * z1
    local x1 = upZ * z0 - upX * z2
    local x2 = upX * z1 - upY * z0
    len = 1 / math.sqrt(x0 * x0 + x1 * x1 + x2 * x2)
    x0 = x0 * len
    x1 = x1 * len
    x2 = x2 * len
    local y0 = z1 * x2 - z2 * x1
    local y1 = z2 * x0 - z0 * x2
    local y2 = z0 * x1 - z1 * x0
    return {
        { x0, y0, z0, 0 },
        { x1, y1, z1, 0 },
        { x2, y2, z2, 0 },
        { -(x0 * eyeX + x1 * eyeY + x2 * eyeZ), -(y0 * eyeX + y1 * eyeY + y2 * eyeZ), -(z0 * eyeX + z1 * eyeY + z2 * eyeZ), 1 },
    }
end

--- 转换4x4矩阵
---@param vec3 number[]
---@param m number[][]
---@return number[]
function matrix.transformMatrix44(vec3, m)
    local x = vec3[1]
    local y = vec3[2]
    local z = vec3[3]
    local rhw = m[1][4] * x + m[2][4] * y + m[3][4] * z + m[4][4]
    rhw = rhw and math.abs(1 / rhw) or 1
    return {
        (m[1][1] * x + m[2][1] * y + m[3][1] * z + m[4][1]) * rhw,
        (m[1][2] * x + m[2][2] * y + m[3][2] * z + m[4][2]) * rhw,
        (m[1][3] * x + m[2][3] * y + m[3][3] * z + m[4][3]) * rhw
    }
end