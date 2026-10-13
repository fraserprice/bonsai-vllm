FROM vllm/vllm-openai:v0.31.0@sha256:b18abb2df97b8f798e81862bd93f872ea18613372e2c3adc0cc2ac21e66ac12f
ENV TORCH_CUDA_ARCH_LIST="8.0 8.6 8.9 9.0 10.0 12.0" \
  TORCH_EXTENSIONS_DIR=/opt/torch_extensions \
  HF_HOME=/cache/huggingface \
  VLLM_CACHE_ROOT=/cache/vllm \
  SAFETENSORS_FAST_GPU=1

COPY . /opt/bonsai-vllm
RUN apt-get update \
  && apt-get install -y --no-install-recommends libcusparse-dev-13-0 libcusolver-dev-13-0 cuda-toolkit ninja-build \
  && rm -rf /var/lib/apt/lists/* \
  && pip install --no-deps --break-system-packages /opt/bonsai-vllm \
  && python3 -c "from prism_ternary.kernels import _cuda; _cuda()"

ENTRYPOINT ["vllm", "serve", "fraserprice/Ternary-Bonsai-2-27B-vllm", \
  "--served-model-name", "Bonsai-2-27B", \
  "--max-model-len", "262144", \
  "--max-num-seqs", "32", \
  "--max-num-batched-tokens", "8192", \
  "--enable-prefix-caching", \
  "--language-model-only", \
  "--reasoning-parser", "qwen3", \
  "--enable-auto-tool-choice", \
  "--tool-call-parser", "qwen3_coder", \
  "--speculative-config", "{\"method\":\"mtp\",\"num_speculative_tokens\":7}"]