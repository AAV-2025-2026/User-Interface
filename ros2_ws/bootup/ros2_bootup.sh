#!/bin/bash

# recall: .sh files are like Windows .bat (batch) files but for Linux...

# Source ROS 2
source /opt/ros/humble/setup.bash

# Source the workspace
source /home/aavui/Desktop/User-Interface/ros2_ws/install/setup.bash

#Wait a bit for network
sleep 5

# Run launch file (ros2 launch files launches multiple ros2 nodes at once)
ros2 launch maincar ros2_launch.xml
