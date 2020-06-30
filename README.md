# WSL2-JupyterHub
JupyterHub install script for WSL2 (with init.d startup)

## EXPERIMENTAL!
I have only tested this on WSL2 in the Windows Insider Dev Channel build 20152

It does work. It works with pre-release GPU compute in WSL2 also. This was tested with TensorFlow ...

## Installation

If you want to try this I recommend you do it in a "clean" WSL Ubuntu 20.04 distro. The following blog post will show you how to create a fresh one. ["Note: How To Copy and Rename a Microsoft WSL Linux Distribution"](https://www.pugetsystems.com/labs/hpc/Note-How-To-Copy-and-Rename-a-Microsoft-WSL-Linux-Distribution-1811/).

- clone or download this repository to your WSL2 Ubuntu home directory
- read the jhub-conda-install-WSL.sh script file so you have an idea of what it's doing
- run the script with sudo
```
sudo ./jhub-conda-install-WSL.sh
```
- start the JupyterHub service with 
```
sudo service jupyterhub start
```
- check your WSL2 Ubuntu ip address
```
ip addr
```
- Connect to the server at that address and port 8000 for the jupyterhub login. For example;
```
 https://172.23.111.110:8000
```
Your browser will complain that the site is not secure. I used a self-signed SSL certificate in JupyterHub so it could be run with https. "Accept the risk" and you should see the JupyterHub login screen.
- login with your Ubuntu username and password

You should be greeted with JupyterLab and a few kernels ready to start working with. Enjoy!

