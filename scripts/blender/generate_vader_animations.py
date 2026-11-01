import bpy
import math

blend_path = "/Users/vincyvincent/darth.blend"
export_path = "/Users/vincyvincent/.gemini/antigravity/scratch/lego-vader-openworld/assets/characters/vader_rigged.glb"

bpy.ops.wm.open_mainfile(filepath=blend_path)

arm_obj = bpy.data.objects.get("Armature_Vader")
if not arm_obj:
    raise RuntimeError("Armature_Vader not found in blend file!")

bpy.context.view_layer.objects.active = arm_obj
bpy.ops.object.mode_set(mode='POSE')

def set_keyframe(pb, data_path, value, frame):
    setattr(pb, data_path, value)
    pb.keyframe_insert(data_path=data_path, frame=frame)

# Clean up existing actions or keep them
print("Initial actions:", [a.name for a in bpy.data.actions])

# Ensure all pose bones have euler rotation mode
for pb in arm_obj.pose.bones:
    pb.rotation_mode = 'XYZ'
    pb.rotation_euler = (0, 0, 0)
    pb.location = (0, 0, 0)

# Helper to create/get action and assign to armature
def create_action(name):
    action = bpy.data.actions.get(name)
    if not action:
        action = bpy.data.actions.new(name=name)
    action.use_fake_user = True
    if not arm_obj.animation_data:
        arm_obj.animation_data_create()
    arm_obj.animation_data.action = action
    return action

# 1. Idle_Casual (Looping 60 frames)
act_idle = create_action("Idle_Casual")
pb_torso = arm_obj.pose.bones["Torso"]
pb_arm_l = arm_obj.pose.bones["Arm_L"]
pb_arm_r = arm_obj.pose.bones["Arm_R"]
pb_head = arm_obj.pose.bones["Head"]
pb_leg_l = arm_obj.pose.bones["Leg_L"]
pb_leg_r = arm_obj.pose.bones["Leg_R"]

# Reset all bones
for pb in arm_obj.pose.bones:
    pb.rotation_euler = (0, 0, 0)
    pb.location = (0, 0, 0)

# Idle keyframes
for frame in [1, 30, 60]:
    t = 0.0 if frame in [1, 60] else 1.0
    # Subtle breathing
    pb_torso.rotation_euler = (math.radians(-1.5 * t), 0, 0)
    pb_head.rotation_euler = (math.radians(1.0 * t), 0, 0)
    # Relaxed arm drape
    pb_arm_l.rotation_euler = (math.radians(5.0 + 2.0 * t), math.radians(2.0), 0)
    pb_arm_r.rotation_euler = (math.radians(5.0 + 2.0 * t), math.radians(-2.0), 0)
    pb_leg_l.rotation_euler = (0, 0, 0)
    pb_leg_r.rotation_euler = (0, 0, 0)
    
    pb_torso.keyframe_insert("rotation_euler", frame=frame)
    pb_head.keyframe_insert("rotation_euler", frame=frame)
    pb_arm_l.keyframe_insert("rotation_euler", frame=frame)
    pb_arm_r.keyframe_insert("rotation_euler", frame=frame)
    pb_leg_l.keyframe_insert("rotation_euler", frame=frame)
    pb_leg_r.keyframe_insert("rotation_euler", frame=frame)

print("Created action: Idle_Casual")

# 2. Walk_Minifig (Classic LEGO Walk Cycle, 40 frames)
# Remember: +X on Leg moves forward, -X moves backward
act_walk = create_action("Walk_Minifig")
for pb in arm_obj.pose.bones:
    pb.rotation_euler = (0, 0, 0)
    pb.location = (0, 0, 0)

# Frames: 1, 10, 20, 30, 40 (1 and 40 identical for seamless loop)
# Frame 1: Passing pose (neutral)
# Frame 10: Left step forward (+X Leg_L, -X Leg_R, -X Arm_L, +X Arm_R)
# Frame 20: Passing pose
# Frame 30: Right step forward (-X Leg_L, +X Leg_R, +X Arm_L, -X Arm_R)
# Frame 40: Passing pose
walk_stride_leg = 28.0
walk_stride_arm = 25.0

keyframes_walk = [
    # frame, leg_l_x, leg_r_x, arm_l_x, arm_r_x, torso_bob_z, torso_roll_y
    (1,   0.0,  0.0,  0.0,  0.0,  0.0,   0.0),
    (10,  walk_stride_leg, -walk_stride_leg, -walk_stride_arm,  walk_stride_arm, -0.015,  1.5),
    (20,  0.0,  0.0,  0.0,  0.0,  0.01,  0.0),
    (30, -walk_stride_leg,  walk_stride_leg,  walk_stride_arm, -walk_stride_arm, -0.015, -1.5),
    (40,  0.0,  0.0,  0.0,  0.0,  0.0,   0.0)
]

for kf in keyframes_walk:
    f, ll, lr, al, ar, tz, tr = kf
    pb_leg_l.rotation_euler = (math.radians(ll), 0, 0)
    pb_leg_r.rotation_euler = (math.radians(lr), 0, 0)
    pb_arm_l.rotation_euler = (math.radians(al), 0, 0)
    pb_arm_r.rotation_euler = (math.radians(ar), 0, 0)
    pb_torso.rotation_euler = (0, math.radians(tr), 0)
    pb_torso.location = (0, 0, tz)
    
    pb_leg_l.keyframe_insert("rotation_euler", frame=f)
    pb_leg_r.keyframe_insert("rotation_euler", frame=f)
    pb_arm_l.keyframe_insert("rotation_euler", frame=f)
    pb_arm_r.keyframe_insert("rotation_euler", frame=f)
    pb_torso.keyframe_insert("rotation_euler", frame=f)
    pb_torso.keyframe_insert("location", frame=f)

print("Created action: Walk_Minifig")

# 3. Run_Minifig (High-energy LEGO sprint, 24 frames)
act_run = create_action("Run_Minifig")
for pb in arm_obj.pose.bones:
    pb.rotation_euler = (0, 0, 0)
    pb.location = (0, 0, 0)

run_stride_leg = 45.0
run_stride_arm = 42.0

keyframes_run = [
    (1,   0.0,  0.0,  0.0,  0.0,  0.0,   0.0),
    (6,   run_stride_leg, -run_stride_leg, -run_stride_arm,  run_stride_arm, -0.03,  2.5),
    (12,  0.0,  0.0,  0.0,  0.0,  0.02,  0.0),
    (18, -run_stride_leg,  run_stride_leg,  run_stride_arm, -run_stride_arm, -0.03, -2.5),
    (24,  0.0,  0.0,  0.0,  0.0,  0.0,   0.0)
]

for kf in keyframes_run:
    f, ll, lr, al, ar, tz, tr = kf
    pb_leg_l.rotation_euler = (math.radians(ll), 0, 0)
    pb_leg_r.rotation_euler = (math.radians(lr), 0, 0)
    pb_arm_l.rotation_euler = (math.radians(al), 0, 0)
    pb_arm_r.rotation_euler = (math.radians(ar), 0, 0)
    # Slight forward torso lean for running
    pb_torso.rotation_euler = (math.radians(8.0), math.radians(tr), 0)
    pb_torso.location = (0, 0, tz)
    
    pb_leg_l.keyframe_insert("rotation_euler", frame=f)
    pb_leg_r.keyframe_insert("rotation_euler", frame=f)
    pb_arm_l.keyframe_insert("rotation_euler", frame=f)
    pb_arm_r.keyframe_insert("rotation_euler", frame=f)
    pb_torso.keyframe_insert("rotation_euler", frame=f)
    pb_torso.keyframe_insert("location", frame=f)

print("Created action: Run_Minifig")

# 4. Guitar_Strum (Acoustic jamming pose, 40 frames)
act_guitar = create_action("Guitar_Strum")
for pb in arm_obj.pose.bones:
    pb.rotation_euler = (0, 0, 0)
    pb.location = (0, 0, 0)

pb_hand_r = arm_obj.pose.bones["Hand_R"]
pb_hand_l = arm_obj.pose.bones["Hand_L"]

for f in [1, 10, 20, 30, 40]:
    t = math.sin((f - 1) / 39.0 * math.pi * 4.0) # 2 strum cycles
    # Left arm holding guitar neck
    pb_arm_l.rotation_euler = (math.radians(35.0), math.radians(15.0), math.radians(-20.0))
    pb_hand_l.rotation_euler = (math.radians(-10.0), 0, 0)
    
    # Right arm strumming
    pb_arm_r.rotation_euler = (math.radians(25.0 + t * 8.0), math.radians(-10.0), math.radians(15.0))
    pb_hand_r.rotation_euler = (math.radians(t * 15.0), 0, 0)
    
    # Head grooving
    pb_head.rotation_euler = (math.radians(4.0 + t * 3.0), 0, math.radians(t * 2.0))
    
    pb_arm_l.keyframe_insert("rotation_euler", frame=f)
    pb_hand_l.keyframe_insert("rotation_euler", frame=f)
    pb_arm_r.keyframe_insert("rotation_euler", frame=f)
    pb_hand_r.keyframe_insert("rotation_euler", frame=f)
    pb_head.keyframe_insert("rotation_euler", frame=f)

print("Created action: Guitar_Strum")

# 5. Bike_Ride_Pose (Speeder bike riding posture, static 10 frames)
act_bike = create_action("Bike_Ride_Pose")
for pb in arm_obj.pose.bones:
    pb.rotation_euler = (0, 0, 0)
    pb.location = (0, 0, 0)

for f in [1, 10]:
    # Minifig seated pose
    pb_leg_l.rotation_euler = (math.radians(72.0), 0, 0)
    pb_leg_r.rotation_euler = (math.radians(72.0), 0, 0)
    # Gripping handlebars
    pb_arm_l.rotation_euler = (math.radians(65.0), math.radians(8.0), math.radians(-10.0))
    pb_arm_r.rotation_euler = (math.radians(65.0), math.radians(-8.0), math.radians(10.0))
    pb_torso.rotation_euler = (math.radians(15.0), 0, 0) # lean into speeder
    pb_head.rotation_euler = (math.radians(-12.0), 0, 0) # head up looking road
    
    pb_leg_l.keyframe_insert("rotation_euler", frame=f)
    pb_leg_r.keyframe_insert("rotation_euler", frame=f)
    pb_arm_l.keyframe_insert("rotation_euler", frame=f)
    pb_arm_r.keyframe_insert("rotation_euler", frame=f)
    pb_torso.keyframe_insert("rotation_euler", frame=f)
    pb_head.keyframe_insert("rotation_euler", frame=f)

print("Created action: Bike_Ride_Pose")

# 6. Lightsaber_Flourish (Defensive saber sweep and stance, 45 frames)
act_saber = create_action("Lightsaber_Flourish")
for pb in arm_obj.pose.bones:
    pb.rotation_euler = (0, 0, 0)
    pb.location = (0, 0, 0)

keyframes_saber = [
    # frame, arm_r_x, arm_r_y, arm_r_z, arm_l_x, torso_y
    (1,   20.0,  -5.0,  10.0,   10.0,   0.0),
    (12,  55.0, -15.0,  30.0,  -15.0,  20.0), # wind up back
    (24, -30.0,  25.0, -25.0,   25.0, -25.0), # horizontal slash arc
    (34,  35.0,   5.0,  15.0,   15.0,  -5.0), # ready guard
    (45,  20.0,  -5.0,  10.0,   10.0,   0.0)  # return to rest
]

for kf in keyframes_saber:
    f, rx, ry, rz, lx, ty = kf
    pb_arm_r.rotation_euler = (math.radians(rx), math.radians(ry), math.radians(rz))
    pb_arm_l.rotation_euler = (math.radians(lx), 0, 0)
    pb_torso.rotation_euler = (0, math.radians(ty), 0)
    
    pb_arm_r.keyframe_insert("rotation_euler", frame=f)
    pb_arm_l.keyframe_insert("rotation_euler", frame=f)
    pb_torso.keyframe_insert("rotation_euler", frame=f)

print("Created action: Lightsaber_Flourish")

# Push all actions onto NLA tracks so glTF exporter captures all of them without dropping any!
if not arm_obj.animation_data:
    arm_obj.animation_data_create()

anim_data = arm_obj.animation_data
# Clear existing tracks
for track in list(anim_data.nla_tracks):
    anim_data.nla_tracks.remove(track)

actions = [act_idle, act_walk, act_run, act_guitar, act_bike, act_saber]
for act in actions:
    track = anim_data.nla_tracks.new()
    track.name = act.name
    strip = track.strips.new(act.name, int(act.frame_range[0]), act)
    strip.action = act

# Save main blend file
bpy.ops.wm.save_mainfile(filepath=blend_path)
print(f"Saved {len(actions)} animations to {blend_path}")

# Now export GLB with all actions
bpy.ops.object.mode_set(mode='OBJECT')
bpy.ops.object.select_all(action='DESELECT')
arm_obj.select_set(True)
bpy.context.view_layer.objects.active = arm_obj
for child in arm_obj.children:
    child.select_set(True)

bpy.ops.export_scene.gltf(
    filepath=export_path,
    export_format='GLB',
    use_selection=True,
    export_apply=False,
    export_animations=True,
    export_animation_mode='ACTIONS',
    export_anim_single_armature=True,
    export_skins=True,
    export_morph=False
)

print(f"Successfully exported rigged Vader with all animations to {export_path}")
