# Making ros2 nodes work on bootup

Goal:
To have ros2 work on startup

How:
a service file runs a shell script which itself launches a launch code.

ros2.service  ->  ros2_launch.sh  ->  launch.py


More detail:
"ros2.service" is what executes on bootup, and will instantly execute the shell file "ros2_launch.sh"
then the shell file contains the command
"ros2 launch <package_name> launch.py"

These are the steps:

1. in the folder ect/systemd,
   create a "ros2.service" file. Next step is to make sure that systemd knows that the new service (the new ros2.service file) exists by using the following commands: 
   
	sudo systemctl daemon-reload          // this refreshes the visiblity of all services inside systemd
	sudo systemctl enable ros2.service    // this turns on the selected service
	sudo systemctl start ros2.service     // this is to test it right away
	
   this will allow to run ros2.service on bootup.
   
2. in the folder <your_ros2_workspace>/bootup,
   create a "ros2_launch.sh" file
   make it executable with "chmod +x"
   make sure you add in this shell file:
   "source <ros2_workspace_path>/install/setup.bash"
   ros2 command "ros2 launch <package_name> launch.py"
   
3. in ros2_ws/src/<package_name>/launch,
   create the "launch.py" file
   this contains what nodes to launch
   
4. edit ros2_ws/setup
   where the data_files="" section includes the launch files
   
5. finally do "colcon build",
   this will take the launch.py file in ros2_ws/src/<package_name>/launch
   and build it in:
   ros2_ws/install/maincar/share/launch.py   
   (which is what ensures the command "ros2 launch <package_name> launch.py" works.
   
   
