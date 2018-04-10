ARG ARCH=i386
ARG DISTRO=xenial

FROM snapcraft/$DISTRO-$ARCH:latest

ARG ROS=kinetic
ENV ROS ${ROS}

# HACK: http://stackoverflow.com/questions/25193161/chfn-pam-system-error-intermittently-in-docker-hub-builds
RUN ln -s -f /bin/true /usr/bin/chfn

COPY public.key /tmp/

RUN apt-get update
RUN apt-get install -y curl software-properties-common python-software-properties
RUN apt-key add /tmp/public.key
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN apt-add-repository http://lcas.lincoln.ac.uk/ubuntu/main
RUN apt-get update && apt-get install -y ros-${ROS}-rospack ros-${ROS}-catkin
RUN bash -c "rm -rf /etc/ros/rosdep; source /opt/ros/indigo/setup.bash;\
        rosdep init"
RUN curl -o /etc/ros/rosdep/sources.list.d/20-default.list https://raw.githubusercontent.com/LCAS/rosdistro/master/rosdep/sources.list.d/20-default.list
RUN curl -o /etc/ros/rosdep/sources.list.d/50-lcas.list https://raw.githubusercontent.com/LCAS/rosdistro/master/rosdep/sources.list.d/50-lcas.list
RUN mkdir -p /root/.config/rosdistro/
RUN echo "index_url: https://raw.github.com/lcas/rosdistro/master/index.yaml" > /root/.config/rosdistro/index.yaml
RUN bash -c "source /opt/ros/indigo/setup.bash;\
        export ROSDISTRO_INDEX_URL="https://raw.github.com/lcas/rosdistro/master/index.yaml"; \
        rosdep update"

ENV ROSDISTRO_INDEX_URL https://raw.github.com/lcas/rosdistro/master/index.yaml

RUN apt-get install -y vim nano less ssh
