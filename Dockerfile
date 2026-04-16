# Latest Ubuntu LTS
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8

# Install requested tools + essential dependencies for XRDP/Shell/Dev
RUN apt-get update && apt-get install -y \
    locales \
    curl \
    wget \
    git \
    git-lfs \
    clang \
    cmake \
    build-essential \
    neovim \
    btop \
    nvtop \
    mc \
    openssh-server \
    iputils-ping \
    zsh \
    bat \
    xrdp \
    xfce4 \
    xfce4-goodies \
    greybird-gtk-theme \
    dbus \
    dbus-x11 \
    xorgxrdp \
    sudo \
    fzf \
    ninja-build \
    ca-certificates
    # && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN update-ca-certificates && locale-gen en_US.UTF-8 

RUN apt-get install -y \
    vulkan-tools mesa-utils \ 
    mesa-vulkan-drivers libvulkan1 \
    libglx0 libgl1 \
    libglx-mesa0 libegl-mesa0

# [DEPRECATED] For NVIDIA GPU support, install the latest drivers and Vulkan support (check compatibility with your GPU model)
# RUN apt-get install -y libnvidia-gl-580

# Check Vulkan version and put right API version below
RUN vulkaninfo | grep -E "apiVersion|deviceName|driverID"

# NVIDIA VULKAN support 
ARG VULKAN_API_VERSION=1.3.0

RUN tee /usr/share/glvnd/egl_vendor.d/10_nvidia.json > /dev/null <<EOF
{
    "file_format_version": "1.0.0",
    "ICD": {
        "library_path": "libEGL_nvidia.so.0"
    }
}
EOF

RUN tee /usr/share/vulkan/icd.d/nvidia_icd.json > /dev/null <<EOF
{
    "file_format_version": "1.0.0",
    "ICD": {
        "library_path": "libGLX_nvidia.so.0",
        "api_version": "${VULKAN_API_VERSION}"
    }
}
EOF

RUN tee /etc/vulkan/implicit_layer.d/nvidia_layers.json > /dev/null <<EOF
{
    "file_format_version": "1.0.0",
    "layer": {
        "name": "VK_LAYER_NV_optimus",
        "type": "INSTANCE",
        "library_path": "libGLX_nvidia.so.0",
        "api_version": "${VULKAN_API_VERSION}",
        "implementation_version": "1",
        "description": "NVIDIA Optimus Layer"
    }
}
EOF

# Verify Vulkan installation and GPU recognition (souldn't be llvmpipe)
RUN vulkaninfo | grep -E "apiVersion|deviceName|driverID"

# Generate SSH host keys & allow root login for development
RUN ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN chsh -s $(which zsh)

# Set default shell to Zsh
SHELL ["/bin/zsh", "-c"]

# Copy custom environment configuration file
COPY .myrc /root/.myrc

# Install Oh-My-Zsh (unattended)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Starship prompt
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- --yes

# Configure Oh-My-Zsh plugins
# Note: Ensure these exist in ~/.oh-my-zsh/custom/plugins/ or they will be ignored
RUN sed -i 's/plugins=(.*)/plugins=(starship git-commit zsh-interactive-cd web-search)/' /root/.zshrc

# Append custom shell configurations to .zshrc
RUN printf '%s\n' \
'# Source custom environment & rules' \
'[ -f /root/.myrc ] && source /root/.myrc' \
'' \
'# PAGER settings (for git particularly)' \
'export PAGER=batcat' \
'alias bat=batcat' \
'' \
'# Quick alias to edit zsh config' \
'alias zrc="nvim ~/.zshrc"' >> /root/.zshrc

# Install Miniforge (Conda-forge distribution)
RUN curl -fsSL -o /tmp/miniforge.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh" \
    && bash /tmp/miniforge.sh -b -p /opt/miniforge \
    && /opt/miniforge/bin/conda init zsh \
    && /opt/miniforge/bin/conda init bash \
    && rm /tmp/miniforge.sh

# Disable auto-activation of base environment
RUN /opt/miniforge/bin/conda config --set auto_activate_base false
    
# Install UV (manager for Python)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Configure XRDP to launch XFCE4 desktop environment
RUN printf '#!/bin/sh\nexec startxfce4\n' > /etc/xrdp/startwm.sh \
    && chmod +x /etc/xrdp/startwm.sh

# Set root password (development environment only)
RUN echo 'root:1234' | chpasswd

# Expose SSH and RDP ports
EXPOSE 22 3389

# Copy & set permissions for the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Entrypoint manages services, CMD provides the interactive shell
ENTRYPOINT ["/entrypoint.sh"]
CMD ["zsh", "--login"]