### How to setup Nerfstudio on VarGPUs

Normally you would just use a conda environment. But currently due to issues with the version of glibc on the servers that IT support say cannot be changed we have to use a Singularity container.

This is sort of like a Docker container but that has no sudo privilages on the host machine.

You first need to build (or use one I've placed in the shared folder) a apptainer.sif file. This is the container that runs an Ubuntu install with all the nerfstudio requirements.

### Intial setup

I reccomend using a folder structure like this:

```shell
/users/$USER/scratch/.apptainer/
-> /users/$USER/scratch/.apptainer/containers/
-> /users/$USER/scratch/.apptainer/pip_venvs/
```

I also recommend:

- Forking nerfstudio
- Structuring your project as an extension module of Nerfstudio
- Implementing Your project as seperate Git repo
- Symlinking a data folder into the project
- Submodule your new project in your nerfstudio fork

```shell
cd /users/$USER/scratch/code/
git clone /url/of/your/nerfstudio/fork
cd /users/$USER/scratch/code/nerfstudio
ln -s /users/$USER/scratch/data/ .
git submodule add /url/of/your/subproject/repo
```

### To build a container

1. Install apptainer: https://apptainer.org/docs/admin/main/installation.html
2. Write a definition file something like the one below, you might need to update nerfstudio version at the top:

```shell
BootStrap: docker
From: dromni/nerfstudio:0.3.3
Stage: spython-base

%post
  touch /etc/localtime
  touch /usr/bin/nvidia-smi
  touch /usr/bin/nvidia-debugdump
  touch /usr/bin/nvidia-persistenced
  touch /usr/bin/nvidia-cuda-mps-control
  touch /usr/bin/nvidia-cuda-mps-server
  mkdir -p /run/nvidia-persistenced
  touch /run/nvidia-persistenced/socket

  apt update
  apt-get -y upgrade
  apt install -y curl
  apt install -y python3.10-venv
  apt-get install -y ffmpeg libglib2.0-0
  apt-get install -y libopenexr-dev libilmbase-dev

  su - user

  su -

  chmod -R 777 /home/user/

  su - user
```

3. Build .sif file on your own machine:

```shell
sudo apptainer build output.sif input.def
```

4. Move .sif file to server

### Using one I built earlier

1. Copy it from the shared folder

```shell
cp /shared/containers/nerfstudio.sif /users/$USER/scratch/.apptainer/containers/ (or your preferred location)
```

2. Copy the bash scripts that launch the container with the correct mounts, this is based off my suggested folder structure earlier.

```shell
cp /shared/containers/apptainer_nerfstudio.sh /your/prefered/location/
cp /shared/containers/apptainer_shell.sh /your/prefered/location/
```

# Installing Nerfstudio

#### 1. Creat a virtual environment:

You can launch singularity with the required arguments using this script. This assumes the apptainer container is as /users/$USER/scratch/.apptainer/containers/nerfstudio.sif.

```shell
#!/bin/bash

apptainer shell --nv --no-home \
  -B /mnt/scratch/users/$USER:/users/$USER/scratch \
  -B /users/$USER/.bashrc:/users/$USER/.bashrc \
  -B /users/$USER/scratch/.config:/users/$USER/.config \
  -B /users/$USER/scratch/.local:/users/$USER/.local \
  -B /users/$USER/scratch/.apptainer/pip_venvs:/mnt \
  -B /users/$USER/.vscode-server:/users/$USER/.vscode-server \
  -B /users/$USER/.jupyter:/users/$USER/.jupyter \
  --env MPLCONFIGDIR=/users/$USER/scratch/.config/matplotlib \
  /users/$USER/scratch/.apptainer/containers/nerfstudio.sif
```

If you save this script as apptainer_shell.sh and placed at /users/$USER/scratch/code/nerfstudio/.devcontainer/
<br>
Then you would run it with

```shell
cd /users/$USER/scratch/code/nerfstudio
./.devcontainer/apptainer.shell.sh
```