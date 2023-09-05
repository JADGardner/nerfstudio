#!/bin/bash
#$ -cwd                        # Run job from current directory
#$ -j y                        # Combine stdout and stderr into a single file
#$ -N reni_neus                # Name of the job
#$ -m bea                      # Send email at the beginning and end of the job and if aborted
#$ -M james.gardner@york.ac.uk # The email address to notify
#$ -pe smp 8                   # 8 cores (8 cores per GPU)
#$ -l h_rt=1:0:0               # 1 hour runtime required to run on the short queue
#$ -l h_vmem=11G               # 11 * 8 = 88G total RAM
#$ -l gpu=1                    # request 1 GPU
#$ -o output_$JOB_ID.txt       # output file

source ~/.bashrc

cd /data/home/$USER/code/nerfstudio

TRAINING_COMMAND="ns-train pnerf --vis wandb"  # Replace with your training command
# TRAINING_COMMAND="cd /data/home/$USER/code/nerfstudio && pip install -e . && cd /data/home/$USER/code/nerfstudio/reni_neus/ns_reni && pip install -e . && cd /data/home/$USER/code/nerfstudio/reni_neus && pip install -e ."

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
