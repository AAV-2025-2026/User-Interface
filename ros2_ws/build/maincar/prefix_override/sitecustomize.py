import sys
if sys.prefix == '/usr':
    sys.real_prefix = sys.prefix
    sys.prefix = sys.exec_prefix = '/home/alex/AV_Project_2025/repos/User-Interface/ros2_ws/install/maincar'
