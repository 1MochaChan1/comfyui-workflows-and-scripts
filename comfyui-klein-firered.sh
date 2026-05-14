#!/usr/bin/env bash

set -e

echo "========================================================="
echo "Installing aria2"
echo "========================================================="

if ! command -v aria2c &> /dev/null; then
  apt update && apt install -y aria2
fi

echo ""
echo "========================================================="
echo "Installing Flash Attention"
echo "========================================================="

pip install --no-cache-dir \
"https://github.com/lesj0610/flash-attention/releases/download/v2.8.3-cu12-torch2.10-cp312/flash_attn-2.8.3%2Bcu12torch2.10cxx11abiTRUE-cp312-cp312-linux_x86_64.whl"

echo ""
echo "========================================================="
echo "Preparing Model Directories"
echo "========================================================="

COMFY_DIR="/workspace/ComfyUI/models"

mkdir -p \
"$COMFY_DIR/diffusion_models" \
"$COMFY_DIR/text_encoders" \
"$COMFY_DIR/vae" \
"$COMFY_DIR/loras"

ARIA2_OPTS="-x 16 -s 16 -k 1M --file-allocation=none"

download () {
  local url=$1
  local out=$2

  echo ""
  echo "Downloading: $(basename "$out")"

  aria2c $ARIA2_OPTS \
    --header="Authorization: Bearer ${HF_TOKEN}" \
    -d "$(dirname "$out")" \
    -o "$(basename "$out")" \
    "$url" &
}

echo ""
echo "========================================================="
echo "FireRed Image Edit 1.1"
echo "========================================================="

download \
"https://huggingface.co/FireRedTeam/FireRed-Image-Edit-1.1-ComfyUI/resolve/main/FireRed-Image-Edit-1.1-transformer.safetensors" \
"$COMFY_DIR/diffusion_models/FireRed-Image-Edit-1.1-transformer.safetensors"

download \
"https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" \
"$COMFY_DIR/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"

download \
"https://huggingface.co/FireRedTeam/FireRed-Image-Edit-1.0-ComfyUI/resolve/main/qwen_image_vae.safetensors" \
"$COMFY_DIR/vae/qwen_image_vae.safetensors"

download \
"https://huggingface.co/FireRedTeam/FireRed-Image-Edit-1.0-ComfyUI/resolve/main/FireRed-Image-Edit-1.0-Lightning-8steps-v1.0.safetensors" \
"$COMFY_DIR/loras/FireRed-Image-Edit-1.0-Lightning-8steps-v1.0.safetensors"

echo ""
echo "========================================================="
echo "Flux2 Klein 9B"
echo "========================================================="

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
echo "========================================================="
echo "Waiting For Downloads"
echo "========================================================="

wait

echo ""
echo "========================================================="
echo "ALL MODEL DOWNLOADS COMPLETE"
echo "========================================================="
