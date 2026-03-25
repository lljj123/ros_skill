---
name: ros1-noetic-general
description: General and comprehensive ROS1 Noetic engineering for any project type (mobile robots, manipulators, perception pipelines, simulation, and OpenClaw integrations). Use when the user asks to build, run, debug, or adapt ROS1 systems, including catkin/rosdep workflows, launch orchestration, topics/services/actions checks, tf/tf2 diagnostics, rosbag workflows, nodelets and dynamic_reconfigure patterns, pluginlib integration, and ROS1↔ROS2 migration planning, plus OpenClaw↔ROS1 rosbridge adaptation.
---

# ROS1 Noetic General

Use this skill for **project-agnostic ROS1 Noetic work**, not only quadruped tasks.

This skill is the single consolidated ROS1 entrypoint and supersedes split usage patterns (for example, separate `ros1-development` guidance).

## Workflow

1. Validate ROS1 environment and active graph.
2. Classify request into a project profile.
3. Execute profile-specific checklist.
4. Apply safe rollout and verification.
5. Report result with reproducible commands.

## Step 1: Validate environment first

Run:

```zsh
zsh scripts/ros1_env_check.sh
zsh scripts/ros1_graph_probe.sh topic
```

If command is missing, source ROS first:

```zsh
source /opt/ros/noetic/setup.zsh
```

If workspace overlays exist, source base first and overlays second.

## Step 2: Choose project profile

- **A. Bringup/Build**: catkin workspace, package dependencies, launch files.
- **B. Runtime Debug**: topics/services/actions, tf tree, node health.
- **C. Motion Control**: velocity/joint commands with feedback checks.
- **D. Data Pipeline**: rosbag record/playback, offline analysis.
- **E. OpenClaw Integration**: rosbridge websocket adaptation and intent mapping.
- **F. Architecture/Performance**: nodelets, callback-threading, message_filters, dynamic_reconfigure.
- **G. Migration Planning**: ROS1 legacy maintenance and ROS1→ROS2 transition strategy.

Read detailed commands from `references/project-profiles.md`.

For full ROS1 coverage (core graph, launch, tf/tf2, actions, bags, diagnostics, networking), load `references/ros1-full-scope.md`.

## Step 3: Execute by profile

### A) Bringup/Build

- Verify workspace structure and package discoverability.
- Build with catkin and stop on first error.
- Validate launch files before runtime.

### B) Runtime Debug

- Confirm graph visibility (`rosnode list`, `rostopic list`).
- Check type/rate/bandwidth for critical topics.
- Verify tf availability and frame consistency.

### C) Motion Control

- Verify command topic type and active subscribers.
- Validate critical interface types explicitly with `scripts/ros1_interface_check.sh`.
- Prefer closed-loop motion if distance/angle is requested.
- Keep conservative defaults and always send explicit stop.

Use interface/type checks first, then run motion script (mobile base profile):

```zsh
zsh scripts/ros1_interface_check.sh topic /cmd_vel geometry_msgs/Twist
python3 scripts/move_forward_by_odom.py \
  --cmd-topic /cmd_vel \
  --odom-topic /odom \
  --distance 1.0 \
  --speed 0.2
```

### D) Data Pipeline

- Record minimal required topics (avoid “record all” unless requested).
- Confirm clock/time behavior in playback scenarios.
- Document bag metadata and replay command for reproducibility.

### E) OpenClaw Integration (ROS1)

- Start ROS1 rosbridge websocket.
- Map high-level intents to ROS1 topic/service/action operations.
- Enforce safety stop semantics for every motion intent.

See `references/ros1-openclaw-adapter.md`.

### F) Architecture / Performance

- Enforce single-responsibility node boundaries.
- Choose queue sizes intentionally for high-rate sensor topics.
- Use `message_filters` for sensor-time synchronization.
- Apply callback threading patterns (`MultiThreadedSpinner` / worker queue).
- Use nodelets for large intra-process data when zero-copy matters.
- Use `dynamic_reconfigure` for runtime tuning instead of hard-coded constants.

See `references/ros1-engineering-patterns.md`.

### G) Migration Planning (ROS1 → ROS2)

- Capture current ROS1 interfaces (topics/services/actions/params) before migration.
- Prefer staged migration from leaf nodes inward.
- Use bridge period planning where mixed ROS1/ROS2 runtime is required.

See `references/ros1-engineering-patterns.md` migration section.

## Step 4: Safety and quality gates

- Never leave a robot/controller moving on function exit.
- Add timeout for every long-running command.
- Fail fast when telemetry is stale or missing.
- Report exact measured outcome (not only “success”).

## Step 5: References

- Official ROS docs and package index links: `references/official-docs.md`
- Full ROS1 capability map and command matrix: `references/ros1-full-scope.md`
- Engineering patterns & migration playbook: `references/ros1-engineering-patterns.md`
- Project-profile checklists and command templates: `references/project-profiles.md`
- OpenClaw↔ROS1 adapter blueprint: `references/ros1-openclaw-adapter.md`
- ROS1 knowledge-base sources ledger (official pages reviewed): `references/ros1-knowledge-base-sources.md`

If `web_fetch` is blocked by anti-bot challenges on official sites, use browser automation (`browser.open` + `browser.snapshot`) to read the page interactively before concluding docs are unavailable.
