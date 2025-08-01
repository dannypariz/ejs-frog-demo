FROM node:16.19.0

ARG JF_TOKEN

# Create app directory
WORKDIR /usr/src/app

# Fix expired Debian Buster sources and install required tools
RUN sed -i 's|http://deb.debian.org|http://archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/security.debian.org/d' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y curl make ncat && \
    apt-get clean

# Install JFrog CLI (v2) - installs to /usr/local/bin
RUN curl -fL https://install-cli.jfrog.io | sh

# Copy package files first to leverage Docker layer caching
COPY package*.json ./

# Authenticate with JFrog and install dependencies (omit dev)
RUN jf c add default \
    --url=https://solengeu.jfrog.io \
    --access-token=${JF_TOKEN} \
    --interactive=false && \
    jf npmc --repo-resolve=dro-npm-unsecure-remote && \
    jf npm i --omit=dev

# Copy application source
COPY server.js ./
COPY public/ public/
COPY views/ views/
COPY fake-creds.txt /usr/src/

EXPOSE 3000

CMD ["node", "server.js"]
