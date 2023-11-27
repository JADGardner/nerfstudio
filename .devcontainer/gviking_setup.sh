#!/bin/bash

source ~/.bashrc

cd /users/$USER/scratch/nerfstudio

python3.10 -m venv /mnt/nerfstduio

source /mnt/nerfstudio/bin/activate

pip install --upgrade pip -y

pip install -e .

cd neusky/ns_reni

pip install -e .

cd ..

pip install -e .

pip install git+https://github.com/NVlabs/tiny-cuda-nn.git@v1.6#subdirectory=bindings/torch