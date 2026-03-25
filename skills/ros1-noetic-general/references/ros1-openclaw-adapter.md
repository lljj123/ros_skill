# OpenClaw ↔ ROS1 Adapter Blueprint (Noetic)

## Goal

Adapt OpenClaw high-level instructions to ROS1 Noetic actions with predictable, safe execution across project types (mobile base, manipulator, perception/inspection workflows).

## Architecture

```text
User instruction
  -> OpenClaw reasoning
  -> ROS1 adapter layer (this skill)
  -> ROS interface
      - Topic publish / subscribe
      - Service calls
      - (Optional) action goals
  -> Robot/application nodes
```

For remote integration:

```text
OpenClaw -> WebSocket (rosbridge) -> ROS1 graph
```

## Minimum prerequisites

- `roscore` active
- ROS1 Noetic environment sourced
- Required control interfaces available (topics/services/actions)
- Required telemetry available for verification (odometry, joint states, task status)

## Intent mapping patterns

### Mobile base pattern

- `forward X m` -> publish `geometry_msgs/Twist` on velocity topic
- stop condition -> odometry displacement/yaw threshold

### Manipulator pattern

- `move joint <name> to <value>` -> publish/call controller-specific joint interface
- stop/verify -> read `/joint_states` and compare tolerance

### Service-driven task pattern

- `start/stop/do task` -> call ROS service
- verify -> check service response + status topic

### Inspection/perception pattern

- `capture/analyze` -> subscribe once to sensor topics or trigger service
- verify -> report timestamp/frame_id and result summary

## Rosbridge notes (OpenClaw integration)

1. Start rosbridge websocket in ROS1:

```zsh
source /opt/ros/noetic/setup.zsh
roslaunch rosbridge_server rosbridge_websocket.launch
```

2. Configure OpenClaw endpoint (commonly `ws://<host>:9090`).
3. Keep operation templates deterministic:
   - topic publish template
   - service call template
   - optional action-goal template
4. Add explicit emergency-stop intent that bypasses complex reasoning.

## Safety defaults

- Always send explicit stop/neutral command on completion and exceptions.
- Add timeout for each long operation.
- Use conservative speed/step defaults unless user overrides.
- Reject execution when required telemetry is missing.

## Failure handling

Stop and return failure if any applies:

- telemetry timeout
- control interface missing or type mismatch
- no measurable progress while commands are sent
- ROS shutdown or transport disconnect

## Validation checklist

1. Interface checks pass (`rostopic type`, `rosservice info`, etc.).
2. Telemetry updates during execution.
3. End-state stop/neutral command sent.
4. Report includes measured result, timeout state, and key topics/services used.
