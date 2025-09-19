FROM python:3.9-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1

# Build tools + git (to fetch the repo)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc g++ cmake git \
    libglib2.0-0 libsm6 libxext6 libxrender1 \
 && rm -rf /var/lib/apt/lists/*

# Tooling + the ONE NumPy version you'll keep (pyradiomics-friendly)
RUN python -m pip install --upgrade pip setuptools wheel \
 && pip install "Cython<3.0" "numpy==1.21.6"

# Force cythonization (uses repo's .pyx/.pxd instead of stale C++)
ENV CYTHONIZE=1

# ✅ Install from GitHub so eigen.pxd is present
RUN pip install --no-cache-dir "pydensecrf @ git+https://github.com/lucasb-eyer/pydensecrf.git"

WORKDIR /app
COPY requirements.txt .

# Make sure requirements.txt does NOT change NumPy version.
# If it has numpy, pin it to the same version (1.21.6).
RUN pip install --no-build-isolation --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir wandb

ENV WANDB_DISABLED=true

COPY . .
CMD ["python", "main.py"]
