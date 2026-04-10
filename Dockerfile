# Latest Ubuntu LTS
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8

# Install requested tools + essential dependencies for XRDP/Shell/Dev
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    dbus-x11 \
    xorgxrdp \
    sudo \
    fzf \
    ca-certificates \
    && update-ca-certificates \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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