---
title: GPU configuration
---

### TensorFlow v2

*   Run interactive session on gpu compute node. GPU nodes starts with `hostname` *winter* while cpu nodes have prefix, *sumner*.

```sh
cd /fastscratch/"$USER"

## requesting partition: gpu with gpu cores of 2
srun --job-name=tflow_gpu --partition=gpu --qos=batch --time=04:00:00 --mem=8G --nodes=1 --ntasks=2 --mail-type=FAIL --export=all--pty --gres gpu:2 bash --login
```

*   Load GPU drivers.
    *   TensorFlow requires CUDA-enabled GPU cards. [Read detailed specifications](https://www.tensorflow.org/install/gpu) under Hardware and Software requirements.

!!! Important "Ask Research IT for exact version"
    GPU drivers, typically from NVIDIA are hardware-specific and not all GPU drivers may work with all hardware versions. Check with Research IT to make sure that required software are installed on gpu nodes as some may need root privileges.

*   Using ==CUDA 10.1.243==

```sh
module load cuda10.1/toolkit/10.1.243

## CUDA_HOME
echo "$CUDA_HOME"

## Check CUDA driver version
cat "$CUDA_HOME"/version.txt
## or
nvcc --version

## For cuDNN
## Ask Research IT if cuDNN library is not installed for a specific CUDA driver
cat "$CUDA_HOME"/include/cudnn.h | grep CUDNN_MAJOR -A 2

## Check GPU card info: Available GPU cores, version, etc.
nvidia-smi 
```

>/cm/shared/apps/cuda10.1/toolkit/10.1.243  
>CUDA release 10.1, V10.1.243  
>cuDNN v7.6.5.32
>NVIDIA-SMI 418.87.01 | Driver Version: 418.87.01 | CUDA Version: 10.1

*   If you do not see cuDNN SDK installed, either contact Research IT or install it by yourself. The latter option requires familiarity with Modulefiles as you may need to clone HPC module and libraries on your end, and then install cuDNN [using this guide](https://docs.nvidia.com/deeplearning/sdk/cudnn-archived/cudnn_741/cudnn-install/index.html#installlinux-tar) or [this SO post](https://stackoverflow.com/a/36978616/1243763).

>Note that guide may be outdated for cuDNN version, and make sure that cuDNN version is aligned to CUDA driver version, i.e., 10.1, installed on gpu nodes.

```sh
cd ~/tmp

tar xvzf cudnn-10.1-linux-x64-v7.6.5.32.tgz

cp cuda/include/cudnn.h <USER_INSTALLED_PATH>/cuda/include
cp cuda/lib64/libcudnn* <USER_INSTALLED_PATH>/cuda/lib64
chmod a+r <USER_INSTALLED_PATH>/include/cudnn.h <USER_INSTALLED_PATH>/cuda/lib64/libcudnn*
```

*   To install, [follow official guide](https://docs.anaconda.com/anaconda/user-guide/tasks/tensorflow/) from anaconda team.

!!! Warning "Prefer creating a dedicated env for tensorflow2 gpu"
    * Prefer using stable tensorflow over nightly builds.
    * Prefer installing CPU vs. GPU versions in separate and new conda env.
    * Avoid loading system modules for CUDA toolkit or other dependencies unless documented in installation guide above.

```sh
## By default, tf now used tf2 over tf1
## Using v2.1.0
conda create -n tf-gpu tensorflow-gpu
conda activate tf-gpu
```

*   Verify install

!!! Tip "Check GPU usage"
    While running tutorials, you may run `watch nvidia-smi` in a separate tmux/screen pane to confirm that gpus and not cpus are being used for computing.

- [x] check tensorflow version

```sh
python -c 'import tensorflow as tf; print(tf.__version__)'
```

>v2.1.0 or higher  

- [x] test run

```sh
python -c "import tensorflow as tf;print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
```

>Should show `Tensor("Sum:0", shape=(), dtype=float32)`.

*   For additional tutorials, [checkout official guide](https://www.tensorflow.org/tutorials/quickstart/beginner).

#### Tensorflow Jupyter Kernel

*   Install [separate kernel](https://ipython.readthedocs.io/en/stable/install/kernel_install.html) for tensorflow jupyter env.

```sh
conda activate tf-gpu

conda install ipykernel
python -m ipykernel install --user --name tf-gpu --display-name "tf-gpu"
```

>This will install a separate python3 kernel at *.local/share/jupyter/kernels/tf-gpu*. So, when you start jupyter notebook even from a default (base) env, `tf-gpu` kernel will show up besides defauly `Python 3` kernel. However, you need to be on compatible GPU compute node to make use of `tf-gpu` kernel.

*   Load valid conda env before loading kernel
    -   While we have installed tf-gpu kernel, it usually loads default or base conda environment and not *tf-gpu* conda env that we created just above. This may land you into issues as PATH and other variables from base env can conflict with conda *tf-gpu* env. You can override environment prior to loading custom kernel, like tf-gpu [using trick from @minrk](https://github.com/jupyterhub/jupyterhub/issues/847#issuecomment-260152425)

*   First make a loading script, say `tf-gpu-env` and place it somewhere outside jupyter kernel dir.

```sh
mkdir -p ~/bin/kernels
nano ~/bin/kernels/tf-gpu-env
```

*   Edit `tf-gpu-env` to load required environment. The last command `exec...` will execute tf-gpu kernel and will inherit your custom loaded environment in jupyter notebook.

!!! Warning "environment variables in notebook"
    Note that all of environment variables, including API tokens, session cookies, etc. if present in environment will be exposed to jupyter notebook. You may unset those in the script below prior to `exec...` command.

```sh
#!/bin/bash

## Load env before loading jupyter kernel
## @sbamin

## https://github.com/jupyterhub/jupyterhub/issues/847#issuecomment-260152425

#### Activate CONDA in subshell ####
## Read https://github.com/conda/conda/issues/7980
CONDA_BASE=$(conda info --base) && \
source "${CONDA_BASE}"/etc/profile.d/conda.sh && \
conda activate tf-gpu
#### END CONDA SETUP ####

## Load CUDA toolkit
module load s7cuda/toolkit/10.1.243

# this is the critical part, and should be at the end of your script:
exec /home/amins/anaconda3/envs/tf-gpu/bin/python -m ipykernel_launcher "$@"

## Make sure to update corresponding kernel.json under ~/.local/share/jupyter/kernels/tf-gpu/kernel.json

#_end_

```

*   Finally, backup `kernel.json` under *~/.local/share/jupyter/kernels/tf-gpu/* and replace it with following.

```json
{
 "argv": [
  "/home/amins/bin/kernels/tf-gpu-env",
  "-f",
  "{connection_file}"
 ],
 "display_name": "tf-gpu",
 "language": "python"
}
```

*   Reload tf-gpu kernel in notebook and run something like `!env`. You will notice a valid tf-gpu conda env instead of default conda base environment.

#### Tensorboard

*   Tensorboard typically comes installed with TensorFlow but conda version of tensorflow (v2.1.0) is shipping with tensorboard 2.1.1 in python 3.8 and not within the conda default python 3.7. This may create problems loading tensorboard as an extension within jupyter notebook. As an interim fix, I've reinstalled tensorboard using `pip`.

??? Error "Error related to opt-einsum package"
    If you get following error but still have tensorboard installed, this should be harmless as long as you have valid *opt-einsum* package.

    ```
    ERROR: tensorflow 2.1.0 has requirement opt-einsum>=2.3.2, but you'll have opt-einsum 0+untagged.56.g2664021.dirty which is incompatible.
    ```

    You can check using `conda list | grep -E "opt-einsum"` or using `pip freeze | grep -E "opt-einsum"`. I already had opt-einsum v3.2.1 but error was likely due to crytpic version name from conda repo.

```sh
conda activate tf-gpu
pip install tensorboard==2.1.1

python -c 'import tensorflow as tf; print(tf.__version__)'
python -c 'import tensorboard as tb; print(tb.__version__)'
```

>TensorFlow: 2.1.0  
>TensorBoard: 2.1.1  

*   [Tensorboard: Getting started guide](https://www.tensorflow.org/tensorboard/get_started)

!!! Tip "Tensorboard server over notebook extension"
    Instead of using tensorboard notebook extension, prefer to run tensorboard as a standalone server, e.g.,

    ```sh
    conda activate tf-gpu && \
    cd <workdir> && \
    tensorboard serve --logdir logs --bind_all
    ```

#### TensorRT

*   Optional install for backward compatibility
*   [Visit TensorRT](https://docs.nvidia.com/deeplearning/sdk/tensorrt-install-guide/index.html) install page for detailed guide.
    -   Make sure to follow requirements given under **Getting Started** section, esp. PyCUDA.
*   [Download tarball](https://developer.nvidia.com/tensorrt) specific to CUDA and cuDNN version, e.g., CUDA 10.1 and cuDNN 7.6 as above. Accordingly, I have downloaded *TensorRT-6.0.1.5.CentOS-7.6.x86_64-gnu.cuda-10.1.cudnn7.6.tar.gz*.
*   [Follow instructions for tar file](https://docs.nvidia.com/deeplearning/sdk/tensorrt-install-guide/index.html#installing-tar) base installation. Know that CUDA and cuDNN versions in default instructions may be misleading and you should instead download TensorRT version based on actual CUDA and cuDNN version installed on your system.

*   Extract tarball

```sh
conda activate tf-gpu

## Make sure to load CUDA libs, including cuDNN libs
module load s7cuda/toolkit/10.1.243

cd /projects/verhaak-lab/amins/sumnerenv_os7/opt/gpu/tensorRT
tar xvzf TensorRT-6.0.1.5.CentOS-7.6.x86_64-gnu.cuda-10.1.cudnn7.6.tar.gz
cd TensorRT-6.0.1.5 
```

*   Temporarily export lib path to LD_LIBRARY_PATH.
    -   After installation, lib path will rather be put in Modulefile.

```sh
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$SUM7ENV/opt/gpu/tensorRT/TensorRT-6.0.1.5/lib"
export LD_LIBRARY_PATH
```

*   Install the Python TensorRT wheel file

```sh
cd python && \
pip install tensorrt-6.0.1.5-cp37-none-linux_x86_64.whl |& install.log
```

    Processing ./tensorrt-6.0.1.5-cp37-none-linux_x86_64.whl
    Installing collected packages: tensorrt
    Successfully installed tensorrt-6.0.1.5


*   Install the Python UFF wheel file: Required for working with TensorFlow2

```sh
cd ../uff && \
pip install uff-0.6.5-py2.py3-none-any.whl |& tee -a install.log && \
command -v convert-to-uff
```

    Processing ./uff-0.6.5-py2.py3-none-any.whl
    Requirement already satisfied: numpy>=1.11.0 in /home/amins/anaconda3/envs/tf-gpu/lib/python3.7/site-packages (from uff==0.6.5) (1.18.1)
    Requirement already satisfied: protobuf>=3.3.0 in /home/amins/anaconda3/envs/tf-gpu/lib/python3.7/site-packages (from uff==0.6.5) (3.11.4)
    Requirement already satisfied: six>=1.9 in /home/amins/anaconda3/envs/tf-gpu/lib/python3.7/site-packages (from protobuf>=3.3.0->uff==0.6.5) (1.14.0)
    Requirement already satisfied: setuptools in /home/amins/anaconda3/envs/tf-gpu/lib/python3.7/site-packages (from protobuf>=3.3.0->uff==0.6.5) (46.1.3.post20200325)
    Installing collected packages: uff
    Successfully installed uff-0.6.5

*   Install the Python graphsurgeon wheel file

```
cd ../graphsurgeon && \
pip install graphsurgeon-0.4.1-py2.py3-none-any.whl |& tee -a install.log
```

    Processing ./graphsurgeon-0.4.1-py2.py3-none-any.whl
    Installing collected packages: graphsurgeon
    Successfully installed graphsurgeon-0.4.1

*   Test compilation and [Hello Word example](https://github.com/NVIDIA/TensorRT/tree/master/samples/opensource/sampleMNIST)

```sh
cd ../samples/sampleMNIST && \
make && \
cd ../../data/mnist && \
## Download MNIST dataset
wget http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz && \
wget http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz && \
wget http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz && \
wget http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz && \

ls *ubyte.gz | parallel -j2 gunzip {} 

./generate_pgms.py && \
cd ../.. && \
./bin/sample_mnist -h && \
./bin/sample_mnist --datadir=data/mnist
```

>Output shows predicted probability of ASCII formatted input number.  

*   After successful install, update Modulefile, **s7cuda/toolkit/10.1.243** by adding TensorRT env configs.

```tcl
# TensorRT
set               tenrthome          /projects/verhaak-lab/amins/sumnerenv_os7/opt/gpu/tensorRT/TensorRT-6.0.1.5
setenv            TENSORRT_HOME       $tenrthome
append-path       LD_LIBRARY_PATH     $tenrthome/lib
append-path       PATH                $tenrthome/bin
```

*   Restart terminal and test again

```sh
conda activate tf-gpu && \
module load s7cuda/toolkit/10.1.243 && \
## sample_mnist will be in PATH
sample_mnist --datadir="$TENSORRT_HOME"/data/mnist
```

### PyTorch

*   Using PyTorch stable build v1.5 for CUDA 10.1, and installing *pytorch-1.4.0-py3.7_cuda10.1.243_cudnn7.6.3_0* conda package along with dependencies.

!!! Important "Using conda installed CUDA toolkit"
    Unlike tensorflow installation which depends on *module load cuda10.1/toolkit/10.1.243*, PyTorch installation will also install CUDA toolkit v10.1. Note that toolkit version must be compatible with GPU card driver, i.e., toolkit v10.1 is compatible with GPU card driver Version: 418.87.01. You can check driver and toolkit compatibility from [NVIDIA Drivers Download](https://www.nvidia.com/Download/index.aspx) page.

```sh
conda activate tf-gpu

## I'd installed matplotlib for other purpose prior to installing pytorch
conda activate matplotlib

## Get updated install cmd from https://pytorch.org
conda install pytorch torchvision cudatoolkit=10.1 -c pytorch
```

*   Verify installation

```py
from __future__ import print_function
import torch
x = torch.rand(5, 3)
print(x)
```

>Above will output a tensor of 5x3 dimensions.
