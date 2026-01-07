# MLz - LLaMA Inference in Zig

MLz is a Zig implementation for running LLaMA language models, primarily utilizing fine-tuned bindings to `llama.cpp` for high-performance inference. It supports hardware acceleration via CUDA and Vulkan, and provides a modern chat interface.

## Quick Start

```bash
# Build the project (Release mode recommended)
zig build -Doptimize=ReleaseFast

# Run inference
.\zig-out\bin\MLz.exe Llama-3.2-3B-Instruct-Q4_K_M.gguf
```

## Hardware Acceleration

MLz supports GPU acceleration out of the box. You can enable it during the build step:

### CUDA (NVIDIA)
```bash
zig build -Dcuda=true -Doptimize=ReleaseFast
```
*Note: On Windows, this requires the CUDA Toolkit and will automatically target the MSVC ABI for compatibility.*

### Vulkan
```bash
zig build -Dvulkan=true -Doptimize=ReleaseFast
```

## Project Structure

```
src/
├── main.zig          # CLI Entry point & Chat Interface
├── llama_cpp.zig     # Zig idiomatic wrapper for llama.cpp
├── root.zig          # Library root
└── ggml_shim.h       # C header shim for GGML/llama.cpp
```

## Features

- **llama.cpp Integration**: Leveraging the industry-standard C++ backend for performance and compatibility.
- **GPU Offloading**: Automatic offloading of model layers to GPU (configurable in `main.zig`).
- **Interactive Chat**: Built-in chat interface with support for initial prompts.
- **Optimized Defaults**: Pre-configured for Llama 3.2 with GQA and KV cache optimization.

## Building from Source

Requirements:
- Zig 0.15.x
- C++ compiler (automatically handled by Zig build system for dependencies)

```bash
# Fetch dependencies and build
zig build

# Build with specific optimization
zig build -Doptimize=ReleaseSmall
```

## Model Compatibility

MLz is tested with **Llama 3.2 3B Instruct** in GGUF format (specifically `Q4_K_M` quantization). Most GGUF models compatible with recent `llama.cpp` versions should work.

Download models from Hugging Face:
```bash
# Example: Llama 3.2 3B Instruct
# Download from unsloth or similar providers
wget https://huggingface.co/unsloth/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf
```
