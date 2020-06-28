#!/usr/bin/env bash

# make sure we are in the script dir
SCRIPT_HOME=$PWD
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
/opt/conda/bin/conda create --yes --name tensorflow2-gpu tensorflow-gpu ipykernel
/opt/conda/envs/tensorflow2.2-cpu/bin/python -m ipykernel install --name 'tensorflow2.2-gpu' --display-name "TensorFlow 2.2 GPU"
cp -a kernel-icons/tensorflow.png /usr/local/share/jupyter/kernels/tensorflow2.2-gpu/logo-64x64.png

# PyTorch 1.5 GPU
/opt/conda/bin/conda create --yes --name pytorch1.5-gpu ipykernel pytorch torchvision -c pytorch 
/opt/conda/envs/pytorch1.5-gpu/bin/python -m ipykernel install --name 'pytorch1.5-gpu' --display-name "PyTorch 1.5 GPU"
cp -a kernel-icons/pytorch-logo-light.png /usr/local/share/jupyter/kernels/pytorch1.5-gpu/logo-64x64.png


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
