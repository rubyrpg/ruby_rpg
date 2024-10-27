# frozen_string_literal: true

module Engine
  class Quaternion
    EULER_ORDER = "XYZ"
    attr_accessor :w, :x, :y, :z, :euler_order

    def initialize(w, x, y, z)
      @w = w
      @x = x
      @y = y
      @z = z
    end

    def to_s
      "Quaternion(w: #{@w}, x: #{@x}, y: #{@y}, z: #{@z})"
    end

    def *(other)
      Quaternion.new(
        @w * other.w - @x * other.x - @y * other.y - @z * other.z,
        @w * other.x + @x * other.w + @y * other.z - @z * other.y,
        @w * other.y - @x * other.z + @y * other.w + @z * other.x,
        @w * other.z + @x * other.y - @y * other.x + @z * other.w
      )
    end

    # taken from https://github.com/mrdoob/three.js/blob/134ff886792734a75c0a9b30aa816d19270f8526/src/math/Quaternion.js#L229
    def self.from_euler(euler)
      e_1 = euler[0] * Math::PI / 180
      e_2 = euler[1] * Math::PI / 180
      e_3 = euler[2] * Math::PI / 180

      c_1 = Math.cos(e_1 / 2)
      c_2 = Math.cos(e_2 / 2)
      c_3 = Math.cos(e_3 / 2)

      s_1 = Math.sin(e_1 / 2)
      s_2 = Math.sin(e_2 / 2)
      s_3 = Math.sin(e_3 / 2)

      case EULER_ORDER
      when "XYZ"
        Quaternion.new(
          c_1 * c_2 * c_3 - s_1 * s_2 * s_3,
          s_1 * c_2 * c_3 + c_1 * s_2 * s_3,
          c_1 * s_2 * c_3 - s_1 * c_2 * s_3,
          c_1 * c_2 * s_3 + s_1 * s_2 * c_3
        )
      when "YXZ"
        Quaternion.new(
          c_1 * c_2 * c_3 + s_1 * s_2 * s_3,
          s_1 * c_2 * c_3 + c_1 * s_2 * s_3,
          c_1 * s_2 * c_3 - s_1 * c_2 * s_3,
          c_1 * c_2 * s_3 - s_1 * s_2 * c_3
        )
      when "ZXY"
        Quaternion.new(
          c_1 * c_2 * c_3 - s_1 * s_2 * s_3,
          s_1 * c_2 * c_3 - c_1 * s_2 * s_3,
          c_1 * s_2 * c_3 + s_1 * c_2 * s_3,
          c_1 * c_2 * s_3 + s_1 * s_2 * c_3
        )
      when "ZYX"
        Quaternion.new(
          c_1 * c_2 * c_3 + s_1 * s_2 * s_3,
          s_1 * c_2 * c_3 - c_1 * s_2 * s_3,
          c_1 * s_2 * c_3 + s_1 * c_2 * s_3,
          c_1 * c_2 * s_3 - s_1 * s_2 * c_3
        )
      when "YZX"
        Quaternion.new(
          s_1 * c_2 * c_3 + c_1 * s_2 * s_3,
          c_1 * s_2 * c_3 + s_1 * c_2 * s_3,
          c_1 * c_2 * s_3 - s_1 * s_2 * c_3,
          c_1 * c_2 * c_3 - s_1 * s_2 * s_3
        )
      when "XZY"
        Quaternion.new(
          c_1 * c_2 * c_3 + s_1 * s_2 * s_3,
          s_1 * c_2 * c_3 - c_1 * s_2 * s_3,
          c_1 * s_2 * c_3 - s_1 * c_2 * s_3,
          c_1 * c_2 * s_3 + s_1 * s_2 * c_3
        )
      end
    end

    # taken from https://github.com/mrdoob/three.js/blob/134ff886792734a75c0a9b30aa816d19270f8526/src/math/Euler.js#L134
    def to_euler
      m11 = te[0]
      m12 = te[4]
      m13 = te[8]
      m21 = te[1]
      m22 = te[5]
      m23 = te[9]
      m31 = te[2]
      m32 = te[6]
      m33 = te[10]

      case EULER_ORDER
      when "XYZ"
        e_y = Math.asin(m13.clamp(-1, 1))

        if m13.abs < 0.9999999
          e_x = Math.atan2(-m23, m33)
          e_z = Math.atan2(-m12, m11)
        else
          e_x = Math.atan2(m32, m22)
          e_z = 0
        end
      when "YXZ"
        e_x = Math.asin(-m23.clamp(-1, 1))

        if m23.abs < 0.9999999
          e_y = Math.atan2(m13, m33)
          e_z = Math.atan2(m21, m22)
        else
          e_y = Math.atan2(-m31, m11)
          e_z = 0
        end
      when "ZXY"
        e_x = Math.asin(m32.clamp(-1, 1))

        if m32.abs < 0.9999999
          e_y = Math.atan2(-m31, m33)
          e_z = Math.atan2(-m12, m22)
        else
          e_y = 0
          e_z = Math.atan2(m21, m11)
        end
      when "ZYX"
        e_y = Math.asin(-m31.clamp(-1, 1))

        if m31.abs < 0.9999999
          e_x = Math.atan2(m32, m33)
          e_z = Math.atan2(m21, m11)
        else
          e_x = 0
          e_z = Math.atan2(-m12, m22)
        end
      when "YZX"
        e_z = Math.asin(m21.clamp(-1, 1))

        if m21.abs < 0.9999999
          e_x = Math.atan2(-m23, m22)
          e_y = Math.atan2(-m31, m11)
        else
          e_x = 0
          e_y = Math.atan2(m13, m33)
        end
      when "XZY"
        e_z = Math.asin(-m12.clamp(-1, 1))

        if m12.abs < 0.9999999
          e_x = Math.atan2(m32, m22)
          e_y = Math.atan2(m13, m11)
        else
          e_x = Math.atan2(-m23, m33)
          e_y = 0
        end
      end

      Vector[e_x, e_y, e_z] * 180 / Math::PI
    end

    def te
      x2 = x + x
      y2 = y + y
      z2 = z + z

      xx = x * x2
      xy = x * y2
      xz = x * z2
      yy = y * y2
      yz = y * z2
      zz = z * z2
      wx = w * x2
      wy = w * y2
      wz = w * z2

      [
        1 - (yy + zz),
        xy + wz,
        xz - wy,
        0,

        xy - wz,
        1 - (xx + zz),
        yz + wx,
        0,

        xz + wy,
        yz - wx,
        1 - (xx + yy),
        0,

        0,
        0,
        0,
        1,
      ]
    end

    def self.from_angle_axis(angle, axis)
      axis = axis.normalize
      angle = angle * Math::PI / 180

      half_angle = angle / 2
      sin_half_angle = Math.sin(half_angle)
      cos_half_angle = Math.cos(half_angle)

      Quaternion.new(
        cos_half_angle,
        axis[0] * sin_half_angle,
        axis[1] * sin_half_angle,
        axis[2] * sin_half_angle
      )
    end

    def to_angle_axis
      angle = 2 * Math.acos(@w)
      s = Math.sqrt(1 - @w * @w)
      s = 1 if s < 0.0001
      axis = Vector[@x / s, @y / s, @z / s]
      [angle * 180 / Math::PI, axis]
    end
  end
end
