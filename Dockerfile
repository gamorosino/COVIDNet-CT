FROM ubuntu:bionic-20200630 


MAINTAINER Gabriele

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install \
                    -y --no-install-recommends \
                     software-properties-common \
                     build-essential \
                     apt-transport-https \
                     ca-certificates \
                     gnupg \
                     software-properties-common \
                     wget \
                     ninja-build \
                      git \
                      zlib1g-dev \
                     apt-utils \
                     g++ \
                     libeigen3-dev \
                     libqt4-opengl-dev libgl1-mesa-dev libfftw3-dev libtiff5-dev \
                     jq \
                     strace \
                     curl \
                     vim \
		     python3-pip \
		     file

## install Conda

ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda2-py27_4.8.3-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

## install Python Modules with Conda

RUN conda install -c anaconda tensorflow-gpu=1.15 python=3.7 \
	&& conda install numpy  python=3.7  \
	&& conda install -c conda-forge  matplotlib  python=3.7 \
	&& conda install -c conda-forge  scikit-lear  python=3.7 \
	&& conda install -c conda-forge opencv=4.2  python=3.7 


## Clone COVIDNet-CT

RUN cd / \
  && git clone https://github.com/gamorosino/COVIDNet-CT.git \
  && cd COVIDNet-CT \
  && git checkout docker


## Download Checkpoints

RUN  cd / \
	&& /bin/bash -c 'source /COVIDNet-CT/utilities.sh;\
	mkdir -p "/COVIDNet-CT/models/";\
	mkdir -p "/COVIDNet-CT/models/COVIDNet-CT-B/";\
	gdrive_download "https://drive.google.com/file/d/1ZdS3Eu2YlQavx-Zw8cG0pNeSKTJxbZEA/view?usp=sharing"  "/COVIDNet-CT/models/model.data-00000-of-00001" ; \ 
	gdrive_download "https://drive.google.com/file/d/1ogrQXQ6gE0XoZNCGw3qzdSnjNQed4U1k/view?usp=sharing"  "/COVIDNet-CT/models/COVIDNet-CT-B/model.index" ; \ 
	gdrive_download "https://drive.google.com/file/d/1VFrIqujLXTEkf0QX888kWaVdyjugNGJR/view?usp=sharing"  "/COVIDNet-CT/models/COVIDNet-CT-B/model.meta" ; \ 
	gdrive_download "https://drive.google.com/file/d/1Rt1v4qgQTnVntI7lQwMeIVlbOolme_PU/view?usp=sharing"  "/COVIDNet-CT/models/COVIDNet-CT-B/checkpoint" ; \ 
	mkdir "/data"; \
	#gdrive_download "" "/data/PROVA.jpg" ;\
	#gdrive_download "" "/data/PROVA_DICOM.dcm" ;\
	#gdrive_download "" "/data/PROVA_PNG.png" ;'

# to cite COVID-Net
#@misc{wang2020covidnet,
#    title={COVID-Net: A Tailored Deep Convolutional Neural Network Design for Detection of COVID-19 Cases from Chest Radiography Images},
#    author={Linda Wang, Zhong Qiu Lin and Alexander Wong},
#    year={2020},
#    eprint={2003.09871},
#    archivePrefix={arXiv},
#    primaryClass={cs.CV}
#}

## Create virtual env

#--user
RUN cd / \
	&& /bin/bash -c  'pip install --upgrade pip;\
	python3 -m pip install  virtualenv; \
	python3 -m venv env ; \
	source env/bin/activate ; \
	pip install --upgrade pip; \
	pip install opencv-python ; \
	pip install tensorflow-io ; \
	pip install tensorflow==2.2.0 ; \
	deactivate ; '

 

#make it work under singularity 
#https://wiki.ubuntu.com/DashAsBinSh 
RUN ldconfig

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
