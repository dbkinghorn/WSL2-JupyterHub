#!/usr/bin/env bash


#
# Install and setup JupyterHub and JupyterLab using Conda
#   ************************* 
#   ***ON WINDOWS 10 WSL2!***
#   *************************
# Will need to use an init file to start the service since WSL2 
# does not use systemd  

# 
SCRIPT_HOME=$PWD

# Install extra packages
apt-get install --yes curl openssl

#
# Install conda (globally)
#

# Add repo
curl -L https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | apt-key add -
echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" | sudo tee  /etc/apt/sources.list.d/conda.list 

# Install
apt-get update
apt-get install --yes conda

# Setup PATH and Environment for conda at user login
ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

#
# Install JupyterHub with conda
#

# source the conda env for root
. /etc/profile.d/conda.sh

# Create conda env for JupyterHub and install it
conda create --yes --name jupyterhub  jupyterhub jupyterlab ipywidgets

# Install nodejs for the http-proxy 
# (seems that nodejs is not getting installed in the env by conda so we will install on system)
apt-get install --yes nodejs npm
npm install -g configurable-http-proxy

#
# create and setup jupyterhub config file
#
mkdir -p /opt/conda/envs/jupyterhub/etc/jupyterhub
cd /opt/conda/envs/jupyterhub/etc/jupyterhub
/opt/conda/envs/jupyterhub/bin/jupyterhub --generate-config
# set default to jupyterlab
sed -i "s/#c\.Spawner\.default_url = ''/c\.Spawner\.default_url = '\/lab'/" jupyterhub_config.py

# Set absolute path to singleuser notebook spawner (default locations is not working in WSL??)
sed -i "s/#c\.Spawner\.cmd = \['jupyterhub-singleuser'\]/c\.Spawner\.cmd = '\/opt\/conda\/envs\/jupyterhub\/bin\/jupyterhub-singleuser'/" jupyterhub_config.py  

# Set path to jupyterhub pid file
sed -i "s/#c\.JupyterHub\.pid_file = ''/c\.JupyterHub\.pid_file = '\/var\/run\/jupyterhub\.pid'/" jupyterhub_config.py

JHUB_HOME=/opt/conda/envs/jupyterhub
JHUB_CONFIG=${JHUB_HOME}/etc/jupyterhub/jupyterhub_config.py

# add SSL cert and key for using https to access hub
mkdir -p ${JHUB_HOME}/etc/jupyterhub/ssl-certs
cd ${JHUB_HOME}/etc/jupyterhub/ssl-certs

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
   -keyout jhubssl.key -out jhubssl.crt \
   -subj "/C=US/ST=Washington/L=Auburn/O=Puget Systems/OU=Labs/CN=Puget Systems Labs Self-Signed" \
   -addext "subjectAltName=DNS:localhost,DNS:localhost,IP:127.0.0.1"

sed -i "s/#c\.JupyterHub\.ssl_cert =.*/c\.JupyterHub\.ssl_cert = '\/opt\/conda\/envs\/jupyterhub\/etc\/jupyterhub\/ssl-certs\/jhubssl.crt'/" ${JHUB_CONFIG}
sed -i "s/#c\.JupyterHub\.ssl_key =.*/c\.JupyterHub\.ssl_key = '\/opt\/conda\/envs\/jupyterhub\/etc\/jupyterhub\/ssl-certs\/jhubssl.key'/" ${JHUB_CONFIG}



#
# Use an init file to start jupyterhub
#

cp -a ${SCRIPT_HOME}/init-file/jupyterhub /etc/init.d/
chown root:root /etc/init.d/jupyterhub

# Insert links using the defaults:
update-rc.d jupyterhub defaults

# Start it up
service jupyterhub start 

#
# Add some extra kernels for JupyterLab
#

# make sure we are in the script dir
cd ${SCRIPT_HOME}

# Anaconda3 
/opt/conda/bin/conda create --yes --name anaconda3 anaconda ipykernel
/opt/conda/envs/anaconda3/bin/python -m ipykernel install --name 'anaconda3' --display-name "Anaconda3 Full"
cp -a kernel-icons/anacondalogo.png /usr/local/share/jupyter/kernels/anaconda3/logo-64x64.png

# TensorFlow 2.2 CPU
/opt/conda/bin/conda create --yes --name tensorflow2.2-cpu tensorflow ipykernel
/opt/conda/envs/tensorflow2.2-cpu/bin/python -m ipykernel install --name 'tensorflow2.2-cpu' --display-name "TensorFlow2.2 CPU"
cp -a kernel-icons/tensorflow.png /usr/local/share/jupyter/kernels/tensorflow2.2-cpu/logo-64x64.png

# PyTorch 1.5
/opt/conda/bin/conda create --yes --name pytorch1.5-cpu ipykernel pytorch torchvision cpuonly -c pytorch 
/opt/conda/envs/pytorch1.5-cpu/bin/python -m ipykernel install --name 'pytorch1.5-cpu' --display-name "PyTorch 1.5 CPU"
cp -a kernel-icons/pytorch-logo-light.png /usr/local/share/jupyter/kernels/pytorch1.5-cpu/logo-64x64.png

# TensorFlow 2.2 GPU
#/opt/conda/bin/conda create --yes --name tensorflow2-gpu tensorflow-gpu ipykernel
#/opt/conda/envs/tensorflow2.2-cpu/bin/python -m ipykernel install --name 'tensorflow2.2-gpu' --display-name "TensorFlow 2.2 GPU"
#cp -a kernel-icons/tensorflow.png /usr/local/share/jupyter/kernels/tensorflow2.2-gpu/logo-64x64.png

# PyTorch 1.5 GPU
#/opt/conda/bin/conda create --yes --name pytorch1.5-gpu ipykernel pytorch torchvision -c pytorch 
#/opt/conda/envs/pytorch1.5-gpu/bin/python -m ipykernel install --name 'pytorch1.5-gpu' --display-name "PyTorch 1.5 GPU"
#cp -a kernel-icons/pytorch-logo-light.png /usr/local/share/jupyter/kernels/pytorch1.5-gpu/logo-64x64.png


#
# Add PSlabs branding to jupyterhub login page
#

# make sure we are in the script dir
cd ${SCRIPT_HOME}

JHUB_HOME=/opt/conda/envs/jupyterhub

cp -a jhub-branding/puget_systems_logo_white.png ${JHUB_HOME}/share/jupyterhub/static/images/
cp -a jhub-branding/pslabs-login.html  ${JHUB_HOME}/share/jupyterhub/templates/

cd ${JHUB_HOME}/share/jupyterhub/templates
mv login.html login.html-orig
ln -s pslabs-login.html login.html
