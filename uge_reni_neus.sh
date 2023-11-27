#!/bin/bash
#$ -cwd                                                 # Run job from current directory
#$ -j y                                                 # Combine stdout and stderr into a single file
#$ -N nerfstudio                                        # Name of the job
#$ -m bea                                               # Send email at the beginning and end of the job and if aborted
#$ -M james.gardner@york.ac.uk                          # The email address to notify
#$ -pe smp 8                                            # 8 cores (8 cores per GPU)
#$ -l h_rt=12:0:0                                       # 1 hour runtime required to run on the short queue
#$ -l h_vmem=11G                                        # 11 * 8 = 88G total RAM
#$ -l gpu=1                                             # request 1 GPU
#$ -l gpu_type=ampere                                   # request an Ampere GPU, A100
#$ -o outputs/uge_logs/output_$JOB_ID.txt   # output file

source ~/.bashrc

cd /data/home/$USER/code/nerfstudio

TRAINING_COMMAND="ns-train neusky --vis wandb"  # Replace with your training command

apptainer exec --nv --no-home \
  -B /data/home/$USER:/data/home/$USER \
  -B /data/home/$USER/.bashrc:/data/home/$USER/.bashrc \
  -B /data/home/$USER/.config:/data/home/$USER/.config \
  -B /data/home/$USER/.local:/data/home/$USER/.local \
  -B /data/home/$USER/.apptainer/pip_venvs:/mnt \
  -B /data/home/$USER/.vscode-server:/data/home/$USER/.vscode-server \
  -B /data/home/$USER/.jupyter:/data/home/$USER/.jupyter \
  --env MPLCONFIGDIR=/data/home/$USER/.config/matplotlib \
  /data/home/$USER/.apptainer/containers/nerfstudio.sif /bin/bash -c "source /mnt/nerfstudio/bin/activate && $TRAINING_COMMAND"
