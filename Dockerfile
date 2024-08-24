# Base image using Node.js Alpine version 22
FROM node:22-alpine AS builder

# Set the working directory for the app
WORKDIR /app

# Copy package.json and pnpm-lock.yaml to install dependencies
COPY pnpm-lock.yaml ./
COPY pnpm-workspace.yaml ./
COPY packages/app-client/package.json packages/app-client/package.json
COPY packages/app-server/package.json packages/app-server/package.json

# Install pnpm
RUN npm install -g pnpm

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the entire app
COPY . .

# Build the apps
RUN pnpm --filter @enclosed/app-client run build
RUN pnpm --filter @enclosed/app-server run build:node

# Production image 
FROM node:22-alpine

WORKDIR /app

# Copy the built apps
COPY --from=builder /app/packages/app-client/dist ./public
COPY --from=builder /app/packages/app-server/dist-node/index.cjs ./index.cjs

EXPOSE 8787

CMD ["node", "index.cjs"]