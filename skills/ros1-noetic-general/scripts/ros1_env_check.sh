#!/usr/bin/env zsh
set -euo pipefail

echo "[ros1-env-check] start"

if ! command -v roscore >/dev/null 2>&1; then
  echo "[ERROR] roscore not found in PATH. Source ROS Noetic first: source /opt/ros/noetic/setup.zsh"
  exit 1
fi

echo "[OK] roscore found: $(command -v roscore)"

if ! command -v rostopic >/dev/null 2>&1; then
  echo "[ERROR] rostopic not found in PATH"
  exit 1
fi

echo "[OK] rostopic found: $(command -v rostopic)"

if ! rosnode list >/dev/null 2>&1; then
  echo "[WARN] Cannot query rosnode list (roscore may be down)"
else
  echo "[OK] ROS master reachable"
fi

echo "[INFO] sample topics (cmd/odom/bridge):"
rostopic list 2>/dev/null | grep -E 'cmd_vel|odom|Odometry|rosbridge' || true

echo "[ros1-env-check] done"
