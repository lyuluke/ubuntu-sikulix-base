FROM ubuntu:18.04

#thanks https://github.com/lzane/Ubuntu-OpenCV3-docker/blob/master/Dockerfile
#thanks https://github.com/unikrn/docker-python-opencv/blob/master/Dockerfile
#thanks https://github.com/kkochubey1/docker_sikuli_chrome_x11vnc

LABEL  maintainer="LK"

COPY entry_point.sh /opt/bin/entry_point.sh

ENV SCREEN_WIDTH 1920
ENV SCREEN_HEIGHT 1200
ENV SCREEN_DEPTH 24
ENV DISPLAY :0
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8

# ubuntu chinese source
RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list \
  && sed -i "s@http://.*security.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list \
  && apt-get update && apt-get -y install sudo && apt-get install -y locales \
  && apt-get -qqy --no-install-recommends install \
    ca-certificates \
    unzip \
    wget \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && sudo useradd seluser --shell /bin/bash --create-home \
  && sudo usermod -a -G sudo seluser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'seluser:a123456789' | chpasswd \
  && apt-get -qqy install openssh-server \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  cd / && \
    wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz -O openjdk-11.0.2_linux-x64_bin.tar.gz && \
    tar zxf openjdk-11.0.2_linux-x64_bin.tar.gz && rm -f openjdk-11.0.2_linux-x64_bin.tar.gz && \
	ln -s /jdk-11.0.2/bin/java /usr/bin/java && \
	mkdir -p /root/SikuliX && \
    cd /root/SikuliX && \
    wget https://raiman.github.io/SikuliX1/sikulixapi.jar -O sikulixapi.jar && \
    wget https://repo1.maven.org/maven2/org/python/jython-standalone/2.7.1/jython-standalone-2.7.1.jar && \
	echo 'deb http://security.ubuntu.com/ubuntu xenial-security main' >> /etc/apt/sources.list && \
	apt-get update --fix-missing && apt-get install tzdata -qy && \
    apt-get install -qy \
    cmake git\
    python-numpy python-scipy python-pip python-setuptools \
    python3-numpy python3-scipy python3-pip python3-setuptools \
    xauth \
    libjpeg-dev libtiff5-dev libjasper1 libjasper-dev libpng-dev libavcodec-dev libavformat-dev \
    libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libgtk2.0-dev libatlas-base-dev \
    libv4l-0 libavutil-dev ffmpeg libavresample-dev libgstreamer1.0-dev \
    vdpau-va-driver libvdpau-va-gl1 vdpauinfo \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-libav gstreamer1.0-vaapi gstreamer1.0-tools \
    gfortran python2.7-dev python3-dev build-essential pkg-config && \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* && \
  cd /root && \
    wget https://github.com/opencv/opencv/archive/3.4.5.tar.gz -O opencv.tar.gz && \
    tar zxf opencv.tar.gz && rm -f opencv.tar.gz && \
    wget https://github.com/opencv/opencv_contrib/archive/3.4.5.tar.gz -O contrib.tar.gz && \
    tar zxf contrib.tar.gz && rm -f contrib.tar.gz && \
    cd opencv-3.4.5 && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=/root/opencv_contrib-3.4.5/modules \
    -D BUILD_DOCS=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_opencv_python2=ON \
    -D BUILD_opencv_python3=ON \
    -D WITH_1394=OFF \
    -D WITH_MATLAB=OFF \
    -D WITH_OPENCL=OFF \
    -D WITH_OPENCLAMDBLAS=OFF \
    -D WITH_OPENCLAMDFFT=OFF \
    -D WITH_GSTREAMER=ON \
    -D WITH_FFMPEG=ON \
    -D CMAKE_CXX_FLAGS="-O3 -funsafe-math-optimizations" \
    -D CMAKE_C_FLAGS="-O3 -funsafe-math-optimizations" \
    .. && make -j $(nproc) && make install && \
    cd /root && rm -rf opencv-3.4.5 opencv_contrib-3.4.5 && \
  apt-get install x11-apps vainfo git -qy && \
    apt-get purge -qy \
    build-essential \
    libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev \
    libv4l-dev libxvidcore-dev libx264-dev libgtk2.0-dev libatlas-base-dev \
    gfortran pkg-config cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install libopencv3.2-java && \
    sudo ln -s /usr/lib/jni/libopencv_java320.so /usr/lib/libopencv_java.so && \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* && \
  apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install libopencv3.2-java && \
    sudo ln -s /usr/lib/jni/libopencv_java320.so /usr/lib/libopencv_java.so && \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* && \
  apt-get update -qqy \
  && apt-get -qqy install \
    xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \ 
  apt-get update -qqy \
  && apt-get -qqy install \
    x11vnc \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p ~/.vnc \
  && x11vnc -storepasswd a123456789 ~/.vnc/passwd \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
  apt-get update -qqy \
  && apt-get -qqy install \
     x.org \
     fluxbox \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
  apt-get update -qqy \
  && apt-get -qqy remove tesseract-ocr* \
    libleptonica-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
  apt-get update -qqy \
  && apt-get autoclean -qqy && sudo apt-get autoremove --purge -qqy \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
  apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
  autoconf automake libtool autoconf-archive pkg-config \
  libpng-dev libjpeg8-dev libtiff5-dev zlib1g-dev libicu-dev \
  libpango1.0-dev libcairo2-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
  cd /root && \
    wget http://www.leptonica.org/source/leptonica-1.74.4.tar.gz -O leptonica-1.74.4.tar.gz && \
    tar zxf leptonica-1.74.4.tar.gz && rm -f leptonica-1.74.4.tar.gz && \
    cd leptonica-1.74.4 && ./configure && make && make install && \
    cd /root && rm -rf leptonica-1.74.4 && \
  cd /root && \
    wget https://github.com/tesseract-ocr/tesseract/archive/3.05.02.tar.gz -O tesseract-3.05.02.tar.gz && \
    tar zxf tesseract-3.05.02.tar.gz && rm -f tesseract-3.05.02.tar.gz && \
    cd tesseract-3.05.02 && ./autogen.sh && ./configure --enable-debug && LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make && \
    sudo make install && sudo make install-langs && sudo ldconfig && \
    cd /root && rm -rf tesseract-3.05.02 && \
  pip3 install py4j && \
  cd /root && \
    wget https://codeload.github.com/RaiMan/sikulix4python/zip/master -O sikulix4python-master.zip && \
    unzip sikulix4python-master.zip && rm -f sikulix4python-master.zip && \
    cp -r /root/sikulix4python-master/sikulix4python   /usr/local/lib/python3.6/dist-packages/ && \
    cd /root &&  rm -rf sikulix4python-master && \
  apt-get update -qqy \
  && sudo apt-get install -y supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
  chmod +x /opt/bin/entry_point.sh && \
  locale-gen en_US.UTF-8 \
  && dpkg-reconfigure --frontend noninteractive locales \
  && apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    language-pack-en \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \	
  apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    fonts-ipafont-gothic \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    xfonts-scalable \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
	
EXPOSE 5900
CMD ["/bin/bash"]
