################################################
##### LLM models
################################################

# Install huggingface CLI
brew install huggingface-cli

# Install llama.cpp
brew install llama.cpp

# Create directory for LLM models
mkdir -p $HOME/llm

# Download Devstral 2 (25-12)
# https://huggingface.co/unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF
# https://unsloth.ai/docs/models/devstral-2
hf download \
"unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF" \
--include "Devstral-Small-2-24B-Instruct-2512-UD-Q4_K_XL.gguf" \
--local-dir "$HOME/llm"

# Download Qwen3.5 9B
# https://huggingface.co/unsloth/Qwen3.5-9B-GGUF
# http://unsloth.ai/docs/models/qwen3.5
hf download \
"unsloth/Qwen3.5-9B-GGUF" \
--include "Qwen3.5-9B-Q5_K_M.gguf" \
--local-dir "$HOME/llm"

# Download Qwen3.5 35B A3B
# https://huggingface.co/unsloth/Qwen3.5-35B-A3B-GGUF
# https://unsloth.ai/docs/models/qwen3.5
hf download \
"unsloth/Qwen3.5-35B-A3B-GGUF" \
--include "Qwen3.5-35B-A3B-Q4_K_M.gguf" \
--local-dir "$HOME/llm"

# Download OmniCoder 9B
# https://huggingface.co/Tesslate/OmniCoder-9B-GGUF
hf download \
"Tesslate/OmniCoder-9B-GGUF" \
--include "omnicoder-9b-q5_k_m.gguf" \
--local-dir "$HOME/llm"

# Download GLM-4.7-Flash
# https://huggingface.co/unsloth/GLM-4.7-Flash-GGUF
# https://unsloth.ai/docs/models/glm-4.7-flash
hf download \
"unsloth/GLM-4.7-Flash-GGUF" \
--include "GLM-4.7-Flash-Q4_K_M.gguf" \
--local-dir "$HOME/llm"

# Download GPT OSS 20b
# https://huggingface.co/unsloth/gpt-oss-20b-GGUF
# https://unsloth.ai/docs/models/gpt-oss-how-to-run-and-fine-tune
hf download \
"unsloth/gpt-oss-20b-GGUF" \
--include "gpt-oss-20b-F16.gguf" \
--local-dir "$HOME/llm"

# Download Qwen3.5 35B A3B
# https://huggingface.co/mradermacher/Qwen3.5-35B-A3B-heretic-Opus-4.6-Distilled-i1-GGUF
hf download \
"mradermacher/Qwen3.5-35B-A3B-heretic-Opus-4.6-Distilled-i1-GGUF" \
--include "Qwen3.5-35B-A3B-heretic-Opus-4.6-Distilled.i1-Q4_K_M.gguf" \
--local-dir "$HOME/llm"

# Download Nemotron Cascade 2 30B A3B
# https://huggingface.co/mradermacher/Nemotron-Cascade-2-30B-A3B-GGUF
hf download \
"mradermacher/Nemotron-Cascade-2-30B-A3B-GGUF" \
--include "Nemotron-Cascade-2-30B-A3B.Q4_K_M.gguf" \
--local-dir "$HOME/llm"

# Download Gemma 4
# https://huggingface.co/collections/unsloth/gemma-4
# https://unsloth.ai/docs/models/gemma-4
hf download \
"unsloth/gemma-4-31B-it-GGUF" \
--include "gemma-4-31B-it-Q4_K_M.gguf" \
--local-dir "$HOME/llm"

hf download \
"unsloth/gemma-4-26B-A4B-it-GGUF" \
--include "gemma-4-26B-A4B-it-UD-Q4_K_M.gguf" \
--local-dir "$HOME/llm"

# Configure aliases
tee ${HOME}/.zshrc.d/llm << 'EOF'
LLAMA_COMMON="--threads 8 --threads-batch 8 --n-gpu-layers 99 --jinja --batch-size 4096 --ubatch-size 2048 --cache-type-k q8_0 --cache-type-v q8_0 --flash-attn on"

alias devstral="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/Devstral-Small-2-24B-Instruct-2512-UD-Q4_K_XL.gguf \
  --alias devstral \
  --ctx-size 65536 \
  --temp 0.15 --min_p 0.01"

alias qwen3.5-9b="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/Qwen3.5-9B-Q5_K_M.gguf \
  --alias qwen3.5-9b \
  --ctx-size 65536 \
  --temp 1.0 --min-p 0.0 --top-p 0.95 --top-k 20 \
  --repeat-penalty 1.00 --presence-penalty 1.5 \
  --chat-template-kwargs '{\"enable_thinking\":false}'"

alias qwen3.5-35b-a3b="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/Qwen3.5-35B-A3B-Q4_K_M.gguf \
  --alias qwen3.5-35b-a3b \
  --ctx-size 65536 \
  --temp 0.6 --min-p 0.0 --top-p 0.95 --top-k 20 \
  --repeat-penalty 1.00 --presence-penalty 0.0 \
  --chat-template-kwargs '{\"enable_thinking\":true}'"

alias qwen3.5-35b-a3b-opus="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/Qwen3.5-35B-A3B-heretic-Opus-4.6-Distilled.i1-Q4_K_M.gguf \
  --alias qwen3.5-35b-a3b-opus \
  --ctx-size 65536 \
  --temp 0.6 --min-p 0.0 --top-p 0.95 --top-k 20 \
  --repeat-penalty 1.00 --presence-penalty 0.0 \
  --chat-template-kwargs '{\"enable_thinking\":true}'"

alias omnicoder="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/omnicoder-9b-q5_k_m.gguf \
  --alias omnicoder \
  --ctx-size 65536 \
  --temp 0.4 --min-p 0.01 --top-p 0.95 --top-k 20 \
  --presence-penalty 0.0 \
  --chat-template-kwargs '{\"enable_thinking\":false}'"

alias glm-4.7-flash="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/GLM-4.7-Flash-Q4_K_M.gguf \
  --alias gml-4.7-flash \
  --ctx-size 65536 \
  --temp 0.7 --min-p 0.01 --top-p 1.0 \
  --repeat-penalty 1.00"

alias gpt-oss-20b="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/gpt-oss-20b-F16.gguf \
  --alias gpt-oss-20b \
  --ctx-size 65536 \
  --temp 1.0 --top-p 1.0 --top-k 0"

alias nemotron-cascade-2-30b-a3b="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/Nemotron-Cascade-2-30B-A3B.Q4_K_M.gguf \
  --alias nemotron-cascade-2-30b-a3b \
  --ctx-size 65536 \
  --temp 1.0 --min-p 0.0 --top-p 0.95 --top-k 0 \
  --repeat-penalty 1.00 --presence-penalty 0.0 \
  --chat-template-kwargs '{\"enable_thinking\":true}'"

alias gemma-4-26b-a4b="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/gemma-4-26B-A4B-it-UD-Q4_K_M.gguf \
  --alias gemma-4-26b-a4b \
  --ctx-size 65536 \
  --temp 1.0 --top-p 0.95 --top-k 64 \
  --chat-template-kwargs '{\"enable_thinking\":true}'"

alias gemma-4-31b="llama-server $LLAMA_COMMON \
  --model \$HOME/llm/gemma-4-31B-it-Q4_K_M.gguf \
  --alias gemma-4-31b \
  --ctx-size 65536 \
  --temp 1.0 --top-p 0.95 --top-k 64 \
  --chat-template-kwargs '{\"enable_thinking\":true}'"
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
