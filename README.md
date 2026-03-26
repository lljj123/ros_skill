# ROS Skills For OpenClaw

This repository contains ROS-oriented skills designed for OpenClaw. The current focus is a general ROS1 Noetic skill that can act as a practical foundation layer for real projects: checking environments, finding workspaces, building packages, discovering launch files, starting long-running targets, monitoring runtime health, stopping processes safely, and providing basic failure attribution.

Instead of treating ROS support as a loose collection of commands, this repository tries to package common ROS operational work into a repeatable interface that OpenClaw can call. The goal is to make routine ROS tasks more predictable, easier to audit, and easier to extend later with domain-specific skills.

## Available skill

`skills/ros1-noetic-general`

This is the main entrypoint today. It is intended to cover the common baseline for ROS1 Noetic work across simulation, mobile robots, manipulators, and general system bringup. It also includes OpenClaw-facing guidance for rosbridge-based control, but its main job is to serve as the broad, reusable base skill before more specialized robot or project skills are added on top.

## What this repository is for

- Giving OpenClaw a reusable ROS1 Noetic operations skill instead of ad hoc shell snippets
- Covering the common path from environment detection to build, launch, runtime checking, and shutdown
- Providing a safer interface for long-running ROS processes by recording state files, logs, and health results
- Creating a stable base layer that later robot-specific or task-specific skills can build on

## What the current skill can do

- Detect whether the machine should use `setup.bash` or `setup.zsh`
- Locate a catkin workspace and suggest the right build command
- Discover launch files inside a workspace
- Run a bringup preflight before build or launch
- Start a ROS target with persistent runtime metadata
- Perform runtime health checks against expected nodes, topics, and services
- Stop previously started targets using the recorded state handle
- Inspect the ROS graph and validate topic or service interface types
- Provide OpenClaw-oriented rosbridge guidance for remote ROS interaction

## Repository layout

- `skills/ros1-noetic-general/SKILL.md`
  The main skill entrypoint. This is where trigger conditions, workflow, and operating guidance live.

- `skills/ros1-noetic-general/references/`
  Reference material for project profiles, full ROS1 scope, engineering patterns, official docs, and OpenClaw integration notes.

- `skills/ros1-noetic-general/scripts/`
  Small helper tools that turn common ROS operations into more repeatable building blocks.

## Script overview

- `ros1_shell_detect.sh`
  Detects the preferred shell context and suggests the most appropriate ROS setup file, such as `setup.zsh` or `setup.bash`.

- `ros1_workspace_probe.sh`
  Finds the nearest ROS1 workspace, counts packages, and suggests a likely build command such as `catkin_make` or `catkin build`.

- `ros1_launch_discover.sh`
  Scans the workspace for launch files and prints candidate `roslaunch` commands.

- `ros1_bringup_check.sh`
  Runs a basic bringup preflight by chaining shell detection, workspace probing, environment checks, and launch discovery.

- `ros1_start_target.sh`
  Starts a `roslaunch` or `rosrun` target in the background and records runtime metadata such as logs, state, and process identifiers for later health checks or stop operations.

- `ros1_runtime_health_check.sh`
  Checks whether a started target is still alive and whether expected ROS graph resources are present.

- `ros1_stop_target.sh`
  Stops a previously started target using the stored runtime handle and cleanup metadata.

- `ros1_env_check.sh`
  Verifies whether ROS commands are available and whether the ROS master is reachable.

- `ros1_graph_probe.sh`
  Lists nodes, topics, or services and can filter them by a name pattern.

- `ros1_interface_check.sh`
  Verifies that a topic or service matches the expected ROS type.

- `move_forward_by_odom.py`
  A small closed-loop motion helper for mobile-base style systems. It publishes forward velocity commands on a `cmd_vel`-style topic, reads odometry from an `odom`-style topic, measures actual traveled distance, and always sends a stop command on completion or failure. In other words, it is not a generic "move the robot" library; it is an example of how this skill handles low-risk, measurable motion with explicit telemetry and timeout rules.

## About `move_forward_by_odom.py`

That Python script exists because motion is one of the places where "just publish a Twist message" is usually not enough. For OpenClaw, and for any agent-like interface, a safer default is to prefer closed-loop behavior whenever a user asks for a measured movement such as "move forward one meter".

The script does four important things:

- It checks that odometry is actually arriving before motion starts.
- It keeps measuring distance from the starting pose instead of assuming command duration equals movement.
- It stops on timeout if the requested motion is not completed in time.
- It publishes an explicit zero-velocity stop command on exit, including failure paths.

That makes it useful as a reference helper for skill behavior, especially in simulation or low-risk mobile-base testing.

## Typical usage flow

For a normal ROS project, the intended flow is:

1. Detect shell and workspace details.
2. Run a bringup preflight.
3. Build the workspace if needed.
4. Discover or select a launch target.
5. Start the target and keep the returned `state_file`.
6. Run runtime health checks against expected nodes, topics, or services.
7. Stop the target cleanly when the task is finished.

For OpenClaw usage, that `state_file` is especially important because it turns a long-running ROS process into something the skill can refer back to later for monitoring and cleanup.

## Trigger behavior

The skill is intended to trigger naturally when a user talks about ROS in either Chinese or English. In practice, that means a request mentioning `ROS`, `ROS1`, `Noetic`, `catkin`, `roslaunch`, `rosrun`, `rospy`, `rostopic`, `rosservice`, `tf`, `rosbag`, `package.xml`, `CMakeLists.txt`, `workspace`, or `rosbridge` should already be a strong match.

The routing idea is simple:

- If the request is mostly about ROS concepts or general knowledge, the skill can stay lightweight and answer at the knowledge layer.
- If the request touches local files, a local workspace, compiling, launching, starting processes, checking health, stopping runtime targets, or debugging a real project, the skill should switch into its local operational workflow.

This makes the skill useful as both a ROS knowledge entrypoint and a practical OpenClaw tool interface, without forcing the user to memorize a command phrase first.

## Prompting tips

You do not have to use a special incantation to trigger the skill. Natural prompts are preferred.

Examples in Chinese:

- `启动 ROS`
- `启动机器狗`
- `帮我编译一下这个 ROS 项目`
- `检查这个 catkin 工作区`
- `帮我看看这个 package.xml 有什么问题`
- `把这个 launch 跑起来`
- `检查一下这个 ROS 节点为什么没起来`

Examples in English:

- `start ROS`
- `start this robot dog bringup`
- `build this ROS project`
- `check this catkin workspace`
- `debug this ROS node`
- `run this roslaunch file`
- `check this package.xml or CMakeLists.txt`

If you want to force the operational path, you can explicitly say:

- `使用 rosskill`
- `用 ros skill`
- `use rosskill`

That is useful when the question could be answered as general ROS knowledge, but you specifically want the skill to inspect local files or execute the local ROS workflow.

## How to ask better

The skill works best when the prompt includes at least one of these anchors:

- The workspace path or package name
- The launch file or node you want to run
- The file you want checked, such as `package.xml`, `CMakeLists.txt`, or a launch file
- The symptom you are seeing, such as build failure, node not starting, missing topic, or runtime crash
- The expected runtime signal, such as a node name, topic, or service that should appear

For example, these are better than a vague "it doesn't work":

- `帮我检查 /home/tong/tong_ws 这个 catkin 工作区，看看为什么 build 失败`
- `use rosskill and start the launch for package vla_nav`
- `检查这个 CMakeLists.txt，看看为什么 ROS 包编译不过`
- `启动这个 ROS 程序后，帮我检查 /chatter 和 /rosout 有没有起来`

The more concrete the target is, the more likely the skill will move from explanation into direct local action.

## Design goals

- Be general enough to support common ROS1 Noetic workflows
- Be structured enough for OpenClaw to treat it as a tool interface, not just documentation
- Keep high-risk operations explicit, especially around real robot motion and system-level changes
- Provide a clean foundation for future specialized skills

## Scope and boundaries

This repository currently targets ROS1 Noetic. It is strongest at foundational operational workflows: environment checks, workspace discovery, launch discovery, runtime control, and practical debugging. It is not yet trying to replace project-specific bringup logic, controller semantics, or robot-specific safety systems.

The OpenClaw integration guidance is included because that is the intended host environment, but the skill is still deliberately written as a general ROS1 base layer first. Specialized robot behaviors should sit on top of this foundation rather than being mixed into it too early.

## Notes

- Target stack: ROS1 Noetic
- Shell scripts are written for `zsh`, but the skill now detects whether the machine prefers `bash` or `zsh` setup files
- Bundled scripts should be resolved relative to the skill directory, not the caller's current working directory
- Motion-related helpers should be used conservatively and with explicit approval on real hardware
