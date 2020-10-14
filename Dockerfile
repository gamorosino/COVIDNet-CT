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
	&& conda install -c conda-forge  scikit-learn  python=3.7 \
	&& conda install -c conda-forge opencv=4.2  python=3.7 


## Clone COVIDNet-CT

RUN cd / \
  && git clone https://github.com/gamorosino/COVIDNet-CT.git \
  && cd COVIDNet-CT \
  && git checkout docker \
  && chmod a+x COVIDNet-CT_inference.sh  


## Download Checkpoints & Sample Data

RUN  cd / \
	&& /bin/bash -c 'source /COVIDNet-CT/utilities.sh;\
	mkdir -p "/COVIDNet-CT/models/";\
	mkdir -p "/COVIDNet-CT/models/COVIDNet-CT-B/";\
	gdrive_download "https://drive.google.com/file/d/1ZdS3Eu2YlQavx-Zw8cG0pNeSKTJxbZEA/view?usp=sharing"  "/COVIDNet-CT/models/COVIDNet-CT-B/model.data-00000-of-00001" ; \ 
	gdrive_download "https://drive.google.com/file/d/1ogrQXQ6gE0XoZNCGw3qzdSnjNQed4U1k/view?usp=sharing"  "/COVIDNet-CT/models/COVIDNet-CT-B/model.index" ; \ 
	gdrive_download "https://drive.google.com/file/d/1VFrIqujLXTEkf0QX888kWaVdyjugNGJR/view?usp=sharing"  "/COVIDNet-CT/models/COVIDNet-CT-B/model.meta" ; \ 
	gdrive_download "https://drive.google.com/file/d/1Rt1v4qgQTnVntI7lQwMeIVlbOolme_PU/view?usp=sharing"  "/COVIDNet-CT/models/COVIDNet-CT-B/checkpoint" ; \ 
	mkdir -p "/data/CT_SAMPLE_DICOM/" ;\
	gdrive_download "https://drive.google.com/file/d/1UDuqKxeQ2hvzbam7t6iA1L1Af0Q-2SK4/view?usp=sharing" "/data/CT_SAMPLE_DICOM/15124679" ;\
	gdrive_download "https://drive.google.com/file/d/1dFRJVT-8d1RkVmLuHej8HrFVT0iSrffN/view?usp=sharing" "/data/CT_SAMPLE_DICOM/76035005" ;\
	gdrive_download "https://drive.google.com/file/d/10BDagpa6g7E9IFZxUac0buN8dO0E6BUm/view?usp=sharing" "/data/CT_SAMPLE_DICOM/76035302" ;\
	gdrive_download "https://drive.google.com/file/d/1Y6XrXWiVAY6F4GS0Ds557rNK_rlaNJX-/view?usp=sharing" "/data/CT_SAMPLE_DICOM/76035643" ;\
	gdrive_download "https://drive.google.com/file/d/14NzS9Gslljcrh-tuIGJEdx7UtESJA16u/view?usp=sharing" "/data/CT_SAMPLE_DICOM/76035665" ;\
	mkdir -p "/data/CT_SAMPLE_JPG/" ;\
	gdrive_download "https://drive.google.com/file/d/1m7BJeKlwkgWfpFc3Nk4McGJI9kbxZypC/view?usp=sharing" "/data/CT_SAMPLE_JPG/15124679.jpg" ;\
	gdrive_download "https://drive.google.com/file/d/18EWmifjo4zVHUIGVfN1PeSE-ysrRxuAC/view?usp=sharing" "/data/CT_SAMPLE_JPG/76035005.jpg" ;\
	gdrive_download "https://drive.google.com/file/d/1D-VKrzqh2qRK5vaTTiQdqn50N64zt8kZ/view?usp=sharing" "/data/CT_SAMPLE_JPG/76035302.jpg" ;\
	gdrive_download "https://drive.google.com/file/d/1tsywWPM8avq8TzqJilYdsyrBrLgMTwjq/view?usp=sharing" "/data/CT_SAMPLE_JPG/76035643.jpg" ;\
	gdrive_download "https://drive.google.com/file/d/1nUcQHUQoHbsAbUFDiBioxH6sYBuGXiWJ/view?usp=sharing" "/data/CT_SAMPLE_JPG/76035665.jpg" ;\
	'

# to cite COVIDNet-CT
#@misc{gunraj2020covidnetct,
#      title={COVIDNet-CT: A Tailored Deep Convolutional Neural Network Design for Detection of COVID-19 Cases from Chest CT Images}, 
#      author={Hayden Gunraj and Linda Wang and Alexander Wong},
#      year={2020},
#      eprint={2009.05383},
#      archivePrefix={arXiv},
#      primaryClass={eess.IV}
#}

## Create virtual env

#--user
RUN cd / \
	&& echo "Create virtual enviroment with pip..." \
	&& /bin/bash -c  'pip install --upgrade pip;\
	python3 -m pip install  virtualenv; \
	python3 -m venv env ; \
	source env/bin/activate ; \
	pip install --upgrade pip; \
	pip install opencv-python ; \
	pip install tensorflow-io==0.13.0 ; \
	pip install tensorflow==2.2.0 ; \
	deactivate ; '

 

#make it work under singularity 
#https://wiki.ubuntu.com/DashAsBinSh 
RUN ldconfig

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
