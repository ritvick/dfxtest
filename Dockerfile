FROM ubuntu:focal

# Install a basic environment needed for our build tools

RUN apt -y update
RUN apt -y install tzdata
RUN apt -yq install wget
#RUN apt -yq install snap
#RUN systemctl enable snapd
RUN apt -yqq install --no-install-recommends curl
RUN apt -yqq install --no-install-recommends ca-certificates 
RUN apt -yqq install --no-install-recommends build-essential 
RUN apt -yqq install --no-install-recommends pkg-config 
RUN apt -yqq install --no-install-recommends libssl-dev 
RUN apt -yqq install --no-install-recommends llvm-dev 
RUN apt -yqq install --no-install-recommends liblmdb-dev 
RUN apt -yqq install --no-install-recommends clang 
RUN apt -yqq install --no-install-recommends cmake

RUN wget https://github.com/dfinity/vessel/releases/download/v0.6.3/vessel-linux64
RUN mv vessel-linux64 /usr/local/bin/vessel
RUN chmod +x /usr/local/bin/vessel

# Install Node.js using nvm
# Specify the Node version
ENV NODE_VERSION=14.17.1
RUN curl --fail -sSf https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Install Rust and Cargo in /opt
# Specify the Rust toolchain version
ARG rust_version=1.54.0
ENV RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    PATH=/opt/cargo/bin:$PATH
RUN curl --fail https://sh.rustup.rs -sSf \
        | sh -s -- -y --default-toolchain ${rust_version}-x86_64-unknown-linux-gnu --no-modify-path && \
    rustup default ${rust_version}-x86_64-unknown-linux-gnu && \
    rustup target add wasm32-unknown-unknown

# Install dfx; the version is picked up from the DFX_VERSION environment variable
ENV DFX_VERSION=0.11.0
RUN sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"

RUN apt -yqq install --no-install-recommends rsync


