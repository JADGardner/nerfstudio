#!/bin/bash
#SBATCH --job-name=nerfstudio                  # Job name
#SBATCH --mail-type=END,FAIL                   # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=james.gardner@york.ac.uk   # Where to send mail
#SBATCH --ntasks=1                             # Run a single task...
#SBATCH --cpus-per-task=16                     # ...with a single CPU
#SBATCH --mem=32gb                             # Job memory request
#SBATCH --time=10:00:00                        # Time limit hrs:min:sec
#SBATCH --output=cuda_job_%j.log               # Standard output and error log
#SBATCH --partition=gpu                        # Select the GPU nodes... (test*, interactive, gpu, gpu_big)  
#SBATCH --gres=gpu:1                           # ...and the Number of GPUs

# This is just printing stuff you don't really need these lines
echo `date`: executing gpu_test on host $HOSTNAME with $SLURM_CPUS_ON_NODE cpu cores echo 
cudaDevs=$(echo $CUDA_VISIBLE_DEVICES | sed -e 's/,/ /g')
echo I can see GPU devices $CUDA_VISIBLE_DEVICES
echo

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
