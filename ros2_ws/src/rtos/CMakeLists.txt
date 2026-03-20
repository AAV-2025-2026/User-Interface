cmake_minimum_required(VERSION 3.8)
project(imu_bridge_qnx)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sensor_msgs REQUIRED)

# Susbcriber executable
add_executable(test_Sub
  src/test_Sub.cpp
)
ament_target_dependencies(test_Sub
  rclcpp
  sensor_msgs
)

# Publisher executable
add_executable(test_Pub
  src/test_Pub.cpp
)
ament_target_dependencies(test_Pub
  rclcpp
  sensor_msgs
)

install(TARGETS
  test_Sub
  test_Pub
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()