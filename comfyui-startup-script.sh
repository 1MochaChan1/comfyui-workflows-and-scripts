#!/usr/bin/env bash

set -e

echo "========================================================="
echo "Install aria2"
echo "========================================================="

if ! command -v aria2c &> /dev/null; then
  echo "aria2c not found, installing..."

  if command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y aria2

  elif command -v pacman &> /dev/null; then
    sudo pacman -Sy --noconfirm aria2

  elif command -v dnf &> /dev/null; then
    sudo dnf install -y aria2

  elif command -v brew &> /dev/null; then
    brew install aria2

  else
    echo "Unsupported package manager."
    exit 1
  fi
fi

echo "aria2c installed." 

# =========================================================
# ComfyUI Model Downloader
# Covers:
# 1. SeedVR2 Upscaler
# 2. Flux Kontext Dev
# 3. Flux2 Dev
# 4. Flux2 Turbo LoRA
# =========================================================

# ======================
# CONFIG
# ======================

COMFY_DIR="/workspace/ComfyUI/models"

ARIA2_OPTS="-x 16 -s 16 -k 1M --file-allocation=none"

# mkdir -p \
#   "$COMFY_DIR/diffusion_models" \
#   "$COMFY_DIR/vae" \
#   "$COMFY_DIR/text_encoders" \
#   "$COMFY_DIR/loras"

download () {
  local url=$1
  local out=$2

  echo ""
  echo "Downloading: $out"

  aria2c $ARIA2_OPTS \
    --header="Authorization: Bearer ${HF_TOKEN}" \
    -d "$(dirname "$out")" \
    -o "$(basename "$out")" \
    "$url"
}


echo "========================================================="
echo "1. SeedVR2"
echo "========================================================="

# =========================================================
# 1. SeedVR2
# =========================================================
# Source workflow: :contentReference[oaicite:0]{index=0}

# download \
# "https://huggingface.co/Kijai/seedvr2_comfy/resolve/main/seedvr2_ema_7b_sharp_fp8_e4m3fn_mixed_block35_fp16.safetensors" \
# "$COMFY_DIR/diffusion_models/seedvr2_ema_7b_sharp_fp8_e4m3fn_mixed_block35_fp16.safetensors"

# download \
# "https://huggingface.co/Kijai/seedvr2_comfy/resolve/main/ema_vae_fp16.safetensors" \
# "$COMFY_DIR/vae/ema_vae_fp16.safetensors"


echo "========================================================="
echo "2. Flux Kontext Dev"
echo "========================================================="

# =========================================================
# 2. Flux Kontext Dev
# =========================================================
# Source workflow: :contentReference[oaicite:1]{index=1}

download \
"https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors" \
"$COMFY_DIR/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors"

download \
"https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors" \
"$COMFY_DIR/vae/ae.safetensors"

download \
"https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" \
"$COMFY_DIR/text_encoders/clip_l.safetensors"

download \
"https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors" \
"$COMFY_DIR/text_encoders/t5xxl_fp8_e4m3fn_scaled.safetensors"

# Optional FP16 T5
download \
"https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" \
"$COMFY_DIR/text_encoders/t5xxl_fp16.safetensors"

echo "========================================================="
echo "3. Flux.2 Dev"
echo "========================================================="

# =========================================================
# 3. Flux2 Dev
# =========================================================
# Source workflow: :contentReference[oaicite:2]{index=2}

download \
"https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/diffusion_models/flux2_dev_fp8mixed.safetensors" \
"$COMFY_DIR/diffusion_models/flux2_dev_fp8mixed.safetensors"

download \
"https://huggingface.co/black-forest-labs/FLUX.2-small-decoder/resolve/main/full_encoder_small_decoder.safetensors" \
"$COMFY_DIR/vae/full_encoder_small_decoder.safetensors"

download \
"https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/text_encoders/mistral_3_small_flux2_bf16.safetensors" \
"$COMFY_DIR/text_encoders/mistral_3_small_flux2_bf16.safetensors"

echo "========================================================="
echo "4. Flux Turbo LoRA"
echo "========================================================="

# =========================================================
# 4. Flux2 Turbo LoRA
# =========================================================
# Source workflow: :contentReference[oaicite:3]{index=3}

download \
"https://huggingface.co/ByteZSzn/Flux.2-Turbo-ComfyUI/resolve/main/Flux_2-Turbo-LoRA_comfyui.safetensors" \
"$COMFY_DIR/loras/Flux_2-Turbo-LoRA_comfyui.safetensors"

echo "========================================================="
echo "5. Flux.2 Klein"
echo "========================================================="

# =========================================================
# 4. Flux2 Klein
# =========================================================

download \
"https://huggingface.co/black-forest-labs/FLUX.2-klein-base-9b-fp8/resolve/main/flux-2-klein-base-9b-fp8.safetensors" \
"$COMFY_DIR/diffusion_models/flux-2-klein-base-9b-fp8.safetensors"

download \
"https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
"$COMFY_DIR/text_encoders/qwen_3_8b_fp8mixed.safetensors"

download \
"https://huggingface.co/black-forest-labs/FLUX.2-small-decoder/resolve/main/full_encoder_small_decoder.safetensors" \
"$COMFY_DIR/vae/full_encoder_small_decoder.safetensors"

echo ""
echo "======================================="
echo "All model downloads completed."
echo "======================================="



echo "========================================================="
echo "CUSTOM NODES"
echo "========================================================="

CUSTOM_NODES_DIR="/workspace/ComfyUI/custom_nodes"

install_node () {
  REPO_URL=$1
  FOLDER_NAME=$2

  TARGET_DIR="$CUSTOM_NODES_DIR/$FOLDER_NAME"

  if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning $FOLDER_NAME..."
    git clone "$REPO_URL" "$TARGET_DIR"
  else
    echo "Updating $FOLDER_NAME..."
    cd "$TARGET_DIR"
    git pull
  fi

  cd "$TARGET_DIR"

  if [ -f requirements.txt ]; then
    echo "Installing requirements for $FOLDER_NAME..."
    pip install -r requirements.txt
  fi

  if [ -f install.py ]; then
    echo "Running install.py for $FOLDER_NAME..."
    python install.py
  fi

  if [ -f install.sh ]; then
    echo "Running install.sh for $FOLDER_NAME..."
    chmod +x install.sh
    ./install.sh
  fi
}

install_node https://github.com/kijai/ComfyUI-KJNodes.git ComfyUI-KJNodes
install_node https://github.com/AInVFX/ComfyUI-SeedVR2_VideoUpscaler.git ComfyUI-SeedVR2_VideoUpscaler
install_node https://github.com/cubiq/ComfyUI_essentials.git ComfyUI_essentials
install_node https://github.com/niknah/quick-connections.git quick-connections
install_node https://github.com/SethRobinson/comfyui-workflow-to-api-converter-endpoint.git comfyui-workflow-to-api-converter-endpoint
install_node https://github.com/Comfy-Org/ComfyUI-Manager.git ComfyUI-Manager
install_node https://github.com/Fannovel16/comfyui_controlnet_aux.git comfyui_controlnet_aux
install_node https://github.com/ltdrdata/ComfyUI-Impact-Pack.git ComfyUI-Impact-Pack
install_node https://github.com/rgthree/rgthree-comfy.git rgthree-comfy
install_node https://github.com/chflame163/ComfyUI_LayerStyle.git ComfyUI_LayerStyle

echo "========================================================="
echo "INSTALLING FLASH-ATTN WHEEL"
echo "========================================================="

pip install --no-cache-dir \
"https://github.com/lesj0610/flash-attention/releases/download/v2.8.3-cu12-torch2.10-cp312/flash_attn-2.8.3%2Bcu12torch2.10cxx11abiTRUE-cp312-cp312-linux_x86_64.whl"

echo "========================================================="
echo "CUSTOM NODES COMPLETE"
echo "========================================================="
