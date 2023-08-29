#!/bin/bash
#SBATCH --job-name=reni_neus
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=james.gardner@york.ac.uk
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64gb
#SBATCH --time=15:00:00
#SBATCH --output=cuda_job_%j.log
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

source ~/.bashrc

TRAINING_COMMAND="ns-train reni-neus --vis wandb"  # Replace with your training command

apptainer exec --nv --no-home \
  -B /mnt/scratch/users/$USER:/users/$USER/scratch \
  -B /users/$USER/.bashrc:/users/$USER/.bashrc \
  -B /users/$USER/scratch/.config:/users/$USER/.config \
  -B /users/$USER/scratch/.local:/users/$USER/.local \
  -B /users/$USER/scratch/.apptainer/pip_venvs:/mnt \
  -B /users/$USER/.vscode-server:/users/$USER/.vscode-server \
  -B /users/$USER/.jupyter:/users/$USER/.jupyter \
  --env MPLCONFIGDIR=/users/$USER/scratch/.config/matplotlib \
  /users/$USER/scratch/.apptainer/containers/nerfstudio.sif /bin/bash -c "source /mnt/nerfstudio/bin/activate && $TRAINING_COMMAND"
