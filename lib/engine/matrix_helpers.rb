# frozen_string_literal: true

module Engine
  module MatrixHelpers
    def look_at(eye, center, up)
      f = (center - eye).normalize
      s = f.cross(up).normalize
      u = s.cross(f)

      Matrix[
        [s[0], s[1], s[2], -s.dot(eye)],
        [u[0], u[1], u[2], -u.dot(eye)],
        [-f[0], -f[1], -f[2], f.dot(eye)],
        [0, 0, 0, 1]
      ]
    end

    def perspective(fov, aspect, near, far)
      tan_half_fov = Math.tan(fov / 2.0)

      Matrix[
        [1.0 / (aspect * tan_half_fov), 0, 0, 0],
        [0, 1.0 / tan_half_fov, 0, 0],
        [0, 0, -(far + near) / (far - near), -(2.0 * far * near) / (far - near)],
        [0, 0, -1, 0]
      ]
    end

    def ortho(left, right, bottom, top, near, far)
      Matrix[
        [2.0 / (right - left), 0, 0, -(right + left) / (right - left)],
        [0, 2.0 / (top - bottom), 0, -(top + bottom) / (top - bottom)],
        [0, 0, -2.0 / (far - near), -(far + near) / (far - near)],
        [0, 0, 0, 1]
      ]
    end
  end
end
