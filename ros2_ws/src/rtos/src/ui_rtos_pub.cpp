#include <iostream>
#include <cstring>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

// basic headers that are needed when writing any publisher node
#include <chrono>
#include <functional>
#include <memory>
#include <string>
#include <thread>

#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/imu.hpp" // needed to use the IMU message type when building the message and sending it to the topic

using namespace std::chrono_literals; // needed to set specfici durations for certain functionalities, ROS2 only understands
                                      // those setting those durations through chrono duration types

struct IMUPacket{ //container representing the structure in which the messages will be stored and sent over at every callback
  float ang_vel_x;
  float ang_vel_y;
  float ang_vel_z;
  float lin_acc_x;
  float lin_acc_y;
  float lin_acc_z;
};

int fn();

IMUPacket pkt;

class QNXPublisher : public rclcpp::Node // public constructor, inherits everything from the Node class
{
                                          // used to build the node when you run the file
  public:
    QNXPublisher() : Node("test_Pub"), count_(0) // public constructor names the node "test_Pub" and initializes count_ to 0

    {
      publisher_ = this->create_publisher<sensor_msgs::msg::Imu>("qnx_imu", 10); // publisher initialized with IMU sensor message type
                                                                                // the name of the topic, "qnx_imu"
                                                                                // the limit amount of messages in the queue before we
                                                                                  // start discarding messages
      timer_ = this->create_wall_timer(500ms, std::bind(&QNXPublisher::timer_callback, this)); // timer_ initialized,causing the
                                                                                              // timer_callback to be executed twice
    }


  private:
    void timer_callback()
      {
        auto message = sensor_msgs::msg::Imu();

        message.header.stamp = this->get_clock()->now();
        message.header.frame_id = "imu_link";



        // message.angular_velocity.x = static_cast<double>(std::rand() % 6);
        // message.angular_velocity.y = static_cast<double>(std::rand() % 6);
        // message.angular_velocity.z = static_cast<double>(std::rand() % 6);
        // message.linear_acceleration.x = static_cast<double>(std::rand() % 6);
        // message.linear_acceleration.y = static_cast<double>(std::rand() % 6);
        // message.linear_acceleration.z = static_cast<double>(std::rand() % 6);

        message.angular_velocity.x = pkt.ang_vel_x;
        message.angular_velocity.y = pkt.ang_vel_y;
        message.angular_velocity.z = pkt.ang_vel_z;
        message.linear_acceleration.x = pkt.lin_acc_x;
        message.linear_acceleration.y = pkt.lin_acc_y;
        message.linear_acceleration.z = pkt.lin_acc_z;


        RCLCPP_INFO(this->get_logger(), "Publishing IMU: %zu  |  angular_velocity = [%.2f,%.2f,%.2f] linear_acceleration = [%.2f,%.2f,%.2f]",
        count_, message.angular_velocity.x, message.angular_velocity.y, message.angular_velocity.z, message.linear_acceleration.x,
        message.linear_acceleration.y, message.linear_acceleration.z);

        publisher_->publish(message);
        count_++;
      }

      rclcpp::TimerBase::SharedPtr timer_;
      rclcpp::Publisher<sensor_msgs::msg::Imu>::SharedPtr publisher_;
      size_t count_;
};

int main(int argc, char * argv[])
{
  rclcpp::init(argc, argv);
  std::thread listener([] {
    fn();
  });
  rclcpp::spin(std::make_shared<QNXPublisher>());
  rclcpp::shutdown();
  return 0;

}


int fn(){

int sock = socket(AF_INET, SOCK_DGRAM, 0); // AF_INET = IPv4, SOCK_DGRAM = UDP behavior, 0 = default protocol for this socket type

struct sockaddr_in recc; //sockaddr_in is structure type of IPv4 socket address
                              //recc = instance of that structure

std::memset(&recc, 0, sizeof(recc)); //clear the entire structure to zero within the instance of the IPv4 structure
recc.sin_family = AF_INET; //defines the address as an IPv4 address
recc.sin_port = htons(5001); //set the destination port (send on and listen on)
recc.sin_addr.s_addr = INADDR_ANY; //set the destination IP address, right now set to local host, later change to IP address of the computer that will have the receiving UPD socket

if (bind(sock, (sockaddr*)&recc, sizeof(recc)) < 0){
    std::cerr << "Bind failed\n";
    close(sock);
    return 1;
}


while(true){

    ssize_t bytes_receied  = recvfrom(sock, &pkt, sizeof(pkt), 0, nullptr, nullptr);




std::cout << "Angular velocity: [" << pkt.ang_vel_x  << "," << pkt.ang_vel_y << "," << pkt.ang_vel_z << "]\n";

std::cout << "Linear Acceleration: [" << pkt.lin_acc_x  << "," << pkt.lin_acc_y << "," << pkt.lin_acc_z << "]\n";

};

close(sock);
return 0;
}
