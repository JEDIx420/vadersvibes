"""Constant-arclength fold math for a folding device, shared by shell
transforms and screen vertices.

Units in math helpers are millimeters (converted to meters at the object
boundary). theta=0 is flat, pi is closed. The flexible band has fixed arc
length (5 mm diameter example); rigid halves are tangent to it. Because the
fold IS this formula, the neutral plane cannot stretch — verification is a
numeric assertion, not a visual guess.
"""
import math
import bpy
from bpy.app.handlers import persistent
from mathutils import Vector

A = 2.5          # band half-length (mm)
HALF_END = 77.0  # rigid half length
WIDTH = 72.0
SCREEN_WIDTH = 68.1


def centerline(y, theta):
    """Position + tangent angle along the constant-arclength bend."""
    if abs(theta) < 1e-7:
        return y, 0.0, 0.0
    k = theta / (2 * A)
    if y <= -A:
        return y, 0, 0
    phi = min(y + A, 2 * A) * k
    yy = -A + math.sin(phi) / k
    zz = (1 - math.cos(phi)) / k
    if y > A:  # rigid half continues at the tangent angle
        yy += (y - A) * math.cos(theta)
        zz += (y - A) * math.sin(theta)
    return yy, zz, phi


def fold_point(x, y, z, theta):
    yy, zz, phi = centerline(y, theta)
    return x, yy - z * math.sin(phi), zz + z * math.cos(phi)


def linkage(theta):
    """Two 5.8 mm rigid links meet at the lower circle-intersection solution.

    Exact by construction: joint sits on the perpendicular bisector at
    sqrt(max(0, L^2 - (d/2)^2)) from the midpoint of the anchors.
    """
    a = Vector((0, -4.7, -2.3))
    b = Vector(fold_point(0, 4.7, -2.3, theta))
    delta = b - a
    distance = delta.length
    perpendicular = Vector((0, delta.z, -delta.y)).normalized()
    joint = (a + b) / 2 + perpendicular * math.sqrt(max(0, 5.8**2 - (distance / 2) ** 2))
    return a, joint, b


def cable_points(theta, count=65):
    """Slack service loop resampled at equal arclength, preserving 31.5 mm.

    Bisection (24 iterations) finds the Bezier handle whose polyline arc
    length hits the target; then resample count points at equal arc length.
    """
    a = Vector((0, -14, -1.15))
    b = Vector(fold_point(0, 14, -1.15, theta))
    slack = 5 * (1 - theta / math.pi)

    def samples(handle, n=160):
        p = a + Vector((0, handle, -slack))
        q = (b - Vector((0, math.cos(theta), math.sin(theta))) * handle
             + Vector((0, math.sin(theta), -math.cos(theta))) * slack)
        return [a * (1 - t) ** 3 + 3 * p * (1 - t) ** 2 * t
                + 3 * q * (1 - t) * t * t + b * t**3
                for t in [i / n for i in range(n + 1)]]

    lo, hi = 0, 45
    for _ in range(24):
        mid = (lo + hi) / 2
        pts = samples(mid)
        length = sum((v - u).length for u, v in zip(pts, pts[1:]))
        if length < 31.5:
            lo = mid
        else:
            hi = mid
    pts = samples((lo + hi) / 2, 512)
    cum = [0]
    for u, v in zip(pts, pts[1:]):
        cum.append(cum[-1] + (v - u).length)
    result = []
    j = 0
    for i in range(count):
        d = cum[-1] * i / (count - 1)
        while j < len(cum) - 2 and cum[j + 1] < d:
            j += 1
        f = (d - cum[j]) / (cum[j + 1] - cum[j])
        result.append(pts[j].lerp(pts[j + 1], f))
    return result


def set_fold(degrees):
    """Drive the whole assembly from one angle. mm -> m at the boundary."""
    control = bpy.data.objects.get("CONTROL | fold and explode")
    if control:
        control["fold_degrees"] = degrees
    theta = math.radians(degrees)
    upper = bpy.data.objects["RIG | upper half"]
    yy, zz, _ = centerline(A, theta)
    upper.rotation_euler[0] = theta
    upper.location = (0, (yy - A * math.cos(theta)) * 0.001,
                      (zz - A * math.sin(theta)) * 0.001)
    # Flexible display: map stored flat positions through the fold.
    display = bpy.data.objects["Display | continuous flexible panel"]
    basis = display.data.attributes.get("flat_position")
    for v, original in zip(display.data.vertices, basis.data):
        x, y, z = original.vector
        v.co = Vector(fold_point(x, y, z, theta)) * 0.001
    display.data.update()
    # Hinge link objects follow the circle-intersection joint positions.
    joints = linkage(theta)
    for obj in bpy.data.objects:
        if "link_x" in obj:
            a, b = joints[obj["link_half"]:obj["link_half"] + 2]
            mid = (a + b) / 2
            mid.x = obj["link_x"]
            obj.location = mid * 0.001
            obj.rotation_euler[0] = math.atan2(b.z - a.z, b.y - a.y)
        if "knuckle_x" in obj:
            p = joints[1].copy()
            p.x = obj["knuckle_x"]
            obj.location = p * 0.001
    bpy.context.view_layer.update()


def animation_angle(frame):
    """Slow, reversible product fold with holds at the extremes."""
    keys = [(1, 8), (12, 8), (60, 177), (75, 177), (128, 8), (144, 8)]
    for (f0, a0), (f1, a1) in zip(keys, keys[1:]):
        if frame <= f1:
            t = max(0, min(1, (frame - f0) / (f1 - f0)))
            t = t * t * (3 - 2 * t)
            return a0 + (a1 - a0) * t
    return keys[-1][1]


@persistent
def on_frame(scene):
    if scene.get("fold_preview_active", False):
        set_fold(animation_angle(scene.frame_current))


def register():
    for handler in list(bpy.app.handlers.frame_change_pre):
        if handler.__name__ == "on_frame":
            bpy.app.handlers.frame_change_pre.remove(handler)
    bpy.app.handlers.frame_change_pre.append(on_frame)
