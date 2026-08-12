################################################
##### LLM models
################################################

# Install huggingface CLI
brew install huggingface-cli

# Install llama.cpp
brew install llama.cpp

# Create directory for LLM models
mkdir -p $HOME/llm

# Download Qwen 3.6 27B (25-12)
# https://huggingface.co/froggeric/Qwen3.6-27B-MTP-GGUF
# https://www.reddit.com/r/LocalLLaMA/comments/1t57xuu/25x_faster_inference_with_qwen_36_27b_using_mtp/
# https://unsloth.ai/docs/models/qwen3.6
hf download \
"froggeric/Qwen3.6-27B-MTP-GGUF" \
--include "Qwen3.6-27B-Q5_K_M-mtp.gguf" \
--local-dir "$HOME/llm"

# Configure aliases
tee ${HOME}/.zshrc.d/llm << 'EOF'
alias qwen3.6-27b="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/Qwen3.6-27B-Q5_K_M-mtp.gguf \
  --alias qwen3.6-27b \
  --ctx-size 128000 \
  --spec-type mtp \
  --spec-draft-n-max 3 \
  --parallel 1 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --min-p 0.0 \
  --presence-penalty 0.0 \
  --repeat-penalty 1.0 \
  --chat-template-kwargs '{\"enable_thinking\":true}' \
  --system-prompt 'You are Qwen, created by Alibaba Cloud. You are a helpful assistant.'"
EOF

################################################
##### AI development
################################################

# qdrant (vectorial database)
podman volume create qdrant_data

podman run -d \
  --name qdrant \
  --restart=always \
  -p 6333:6333 \
  -v qdrant_data:/qdrant/storage \
  qdrant/qdrant

# Install specify
# https://github.com/github/spec-kit
brew install specify

# Install opencode
# https://github.com/anomalyco/opencode
brew install anomalyco/tap/opencode
