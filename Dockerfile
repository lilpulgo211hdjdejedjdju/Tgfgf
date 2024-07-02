# Copyright (c) 2020-2022, NVIDIA CORPORATION.
# All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto. Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.

ARG BASE_IMAGE=nvcr.io/nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04
FROM $BASE_IMAGE

WORKDIR /

RUN apt-get update -yq --fix-missing \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    pkg-config \
    wget \
    cmake \
    curl \
    git \
    vim

# Download and install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN sh Miniconda3-latest-Linux-x86_64.sh -b -u -p ~/miniconda3
RUN ~/miniconda3/bin/conda init
RUN echo ". ~/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc
RUN echo "conda activate nerfstream" >> ~/.bashrc

# Create conda environment
RUN ~/miniconda3/bin/conda create -n nerfstream python=3.10 -y
RUN ~/miniconda3/bin/conda install pytorch==1.12.1 torchvision==0.13.1 cudatoolkit=11.3 -c pytorch -n nerfstream -y

# Set pip source
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# Install requirements
COPY .. /

RUN ~/miniconda3/envs/nerfstream/bin/pip install -r requirements.txt

# Install additional libraries
RUN ~/miniconda3/envs/nerfstream/bin/pip install "git+https://github.com/facebookresearch/pytorch3d.git"
RUN ~/miniconda3/envs/nerfstream/bin/pip install tensorflow-gpu==2.8.0

# Fix protobuf version
RUN ~/miniconda3/envs/nerfstream/bin/pip uninstall protobuf -y
RUN ~/miniconda3/envs/nerfstream/bin/pip install protobuf==3.20.1

# Install ffmpeg
RUN ~/miniconda3/bin/conda install -c conda-forge ffmpeg -n nerfstream -y

# Copy application files
#COPY ./python_rtmpstream /app/python_rtmpstream
RUN ~/miniconda3/envs/nerfstream/bin/pip install /app/python_rtmpstream

#COPY ./nerfstream /nerfstream

# Expose ports
EXPOSE 1935 8080 1985 8000

# Define the command to run the application
CMD ["~/miniconda3/envs/nerfstream/bin/python", "/app/nerfstream/app.py"]
