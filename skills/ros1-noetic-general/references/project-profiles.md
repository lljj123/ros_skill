# ROS1 Noetic Project Profiles

Use this file to choose commands/checklists based on project type.

## A) Bringup / Build Profile

### Goals

- Build catkin workspace reliably
- Launch nodes with deterministic config

### Checklist

1. Confirm ROS environment sourced.
2. Confirm workspace root and `src/` layout.
3. Install dependencies (`rosdep`) if needed.
4. Build (`catkin_make` or project-specific command).
5. Validate launch files.

### Commands

```zsh
# workspace example
source /opt/ros/noetic/setup.zsh
cd <ws_root>
catkin_make
source devel/setup.zsh

# validate package and launch visibility
rospack list | head
roslaunch --help
```

## B) Runtime Debug Profile

### Goals

- Explain why graph behavior differs from expectations

### Checklist

1. Node existence and namespace check.
2. Topic type/rate consistency.
3. Service/action availability.
4. TF frame chain sanity.

### Commands

```zsh
rosnode list
rostopic list
rostopic type <topic>
rostopic hz <topic>
rosservice list

# tf diagnostics (if installed in environment)
# rosrun tf view_frames
# rosrun tf tf_echo <from> <to>
```

## C) Motion Control Profile

### Goals

- Execute movement safely with measurable completion

### Checklist

1. Verify command topic (e.g., `/cmd_vel` or joint command topics).
2. Verify feedback telemetry (odometry/joint states).
3. Apply conservative speed and timeout.
4. Issue explicit stop at end and on error.

### Commands

```zsh
zsh scripts/ros1_interface_check.sh topic /cmd_vel geometry_msgs/Twist
rostopic echo -n 1 /odom

# example closed-loop move
python3 scripts/move_forward_by_odom.py --cmd-topic /cmd_vel --odom-topic /odom --distance 1.0
```

## C2) Manipulator / Joint-Control Variant

### Goals

- Execute joint-space or controller-service operations safely

### Checklist

1. Confirm `/joint_states` is updating.
2. Confirm target controller topic/service exists and type matches.
3. Apply bounded increments and timeout.
4. Verify final joint tolerance before reporting success.

### Commands

```zsh
rostopic echo -n 1 /joint_states
# Example type check (replace with your actual control interface)
# zsh scripts/ros1_interface_check.sh topic /arm_controller/command <msg_type>
```

## D) Data Pipeline Profile

### Goals

- Capture/replay data for debugging or evaluation

### Checklist

1. Select minimal topic set.
2. Record with clear naming and timestamps.
3. Capture metadata (`rosbag info`).
4. Replay with expected clock settings.

### Commands

```zsh
rosbag record /cmd_vel /odom
rosbag info <file.bag>
rosbag play <file.bag>
```

## E) OpenClaw Integration Profile (ROS1)

### Goals

- Bridge OpenClaw intents to ROS1 operations

### Checklist

1. Start `rosbridge_server` websocket.
2. Validate websocket endpoint accessibility.
3. Map intent -> ROS operation (topic/service/action).
4. Add emergency stop path and timeout fallback.

### Commands

```zsh
roslaunch rosbridge_server rosbridge_websocket.launch
# default websocket endpoint: ws://<host>:9090
```

## Notes

- Choose profile first, then run only relevant checks.
- Keep outputs reproducible: include exact commands and measured values.
- For architecture/performance tuning (nodelets, callback threading, dynamic_reconfigure), see `ros1-engineering-patterns.md`.
- For migration planning, use `ros1-engineering-patterns.md` migration checklist with `ros1-full-scope.md` interface inventory rules.
