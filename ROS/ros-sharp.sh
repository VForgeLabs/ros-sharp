    ros_distro='kinetic'

    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

    apt-get update -y
    apt-get install -y "ros-${ros_distro}-ros-base"
    apt-get install -y "ros-${ros_distro}-ros-tutorials"
    apt-get install -y "ros-${ros_distro}-common-tutorials"
    apt-get install -y "ros-${ros_distro}-rosbridge-server"
    apt-cache search ros-kinetic
    rosdep init
    su vagrant -c 'rosdep update'

    # Ensure updates to .bashrc are idempotent
    if ! grep -q "${ros_distro}/setup.bash" ~/.bashrc; then
      echo "source /opt/ros/${ros_distro}/setup.bash" >> ~/.bashrc
    fi
    apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential
    sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
    wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
    sudo apt-get -y update
    sudo apt-get -y install gazebo7
    apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE
    sudo add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u
    apt-get install -y librealsense2-dkms
    apt-get install -y librealsense2-utils
    sudo apt-get install -y ros-kinetic-turtlebot ros-kinetic-turtlebot-apps ros-kinetic-turtlebot-interactions ros-kinetic-turtlebot-simulator ros-kinetic-kobuki-ftdi ros-kinetic-ar-track-alvar-msgs ros-kinetic-turtlebot-gazebo
    export TURTLEBOT_BASE=roomba
    export TURTLEBOT_STACKS=circles
    export TURTLEBOT_3D_SENSOR=kinect
    if ! grep -q "export TURTLEBOT_BASE=roomba" ~/.bashrc; then
      echo export TURTLEBOT_BASE=roomba >> ~/.bashrc
    fi
    if ! grep -q "TURTLEBOT_STACKS=circles" ~/.bashrc; then
      echo export TURTLEBOT_STACKS=circles >> ~/.bashrc
    fi
    if ! grep -q "TURTLEBOT_3D_SENSOR=kinect" ~/.bashrc; then
      echo export TURTLEBOT_3D_SENSOR=kinect >> ~/.bashrc
    fi
    apt-get -y install python-xlib

    mkdir -p ~/catkin_ws/src && chown -R vagrant:vagrant ~/catkin_ws/
    cp -r file_server/ ~/catkin_ws/src/file_server/
    cp -r unity_simulation_scene ~/catkin_ws/src/unity_simulation_scene/
    chmod +x ~/catkin_ws/src/unity_simulation_scene/scripts/mouse_to_joy.py
    pushd ~/catkin_ws/ && catkin_make && popd
    source ~/catkin_ws/devel/setup.bash
    pushd ~/catkin_ws/ && catkin_make install && popd
    echo 'run roslaunch file_server publish_description_turtlebot2.launch'
