FROM node:16.19.0

ARG JF_TOKEN

# Create app directory
WORKDIR /usr/src/app

# Install dependencies & tools
RUN apt-get update && \
    apt-get install -y curl make ncat && \
    apt-get clean

# Install JFrog CLI (v2) and add to PATH
RUN curl -fL https://install-cli.jfrog.io | sh && \
    mv jf /usr/local/bin/

# Copy package files first to leverage layer caching
COPY package*.json ./

# Authenticate JFrog CLI and install npm deps (omit dev)
RUN jf c import ${JF_TOKEN} && \
    jf npmc --repo-resolve=dro-npm-unsecure-remote && \
    jf npm i --omit=dev

# Copy app code
COPY server.js ./
COPY public/ public/
COPY views/ views/
COPY fake-creds.txt /usr/src/

EXPOSE 3000

CMD ["node", "server.js"]
