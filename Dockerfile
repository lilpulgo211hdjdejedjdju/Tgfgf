# Copyright (c) 2020-2022, NVIDIA CORPORATION.
# All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto. Any use, reproduction, disclosure, or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.

ARG BASE_IMAGE=nvcr.io/nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04
FROM $BASE_IMAGE

# Set the working directory to /app
WORKDIR /app

COPY . .

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    pkg-config \
    wget \
    cmake \
    curl \
    git \
    vim \
    python3 \
    python3-pip

# Set pip source
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# Upgrade pip and install dependencies
RUN python3 -m pip install --upgrade pip

# Install requirements
RUN python3 -m pip install -r requirements.txt

# Install additional libraries
RUN python3 -m pip install "git+https://github.com/facebookresearch/pytorch3d.git"
RUN python3 -m pip install tensorflow-gpu==2.8.0

# Fix protobuf version
RUN python3 -m pip uninstall protobuf -y
RUN python3 -m pip install protobuf==3.20.1

# Install ffmpeg
RUN apt-get install -yq ffmpeg

# Expose ports
EXPOSE 1935 8080 1985 8000

# Define the command to run the application
CMD ["python3", "app.py"]
