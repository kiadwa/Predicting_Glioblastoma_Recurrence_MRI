FROM python:3.9-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1

# Build tools + runtime libs for matplotlib/SimpleITK
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc g++ cmake \
    libglib2.0-0 libsm6 libxext6 libxrender1 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .

# 1) Tools + NumPy first (needed for pyradiomics' setup.py)
RUN python -m pip install --upgrade pip setuptools wheel \
 && pip install "numpy==1.21.6"

# 2) Install the rest; disable build isolation so setup.py can import NumPy
RUN pip install --no-build-isolation --no-cache-dir -r requirements.txt  \
    && pip install --no-cache-dir wandb      

ENV WANDB_DISABLED=true

# 3) Your code
COPY . .
# uncomment if you always run this
CMD ["python", "main.py"]
