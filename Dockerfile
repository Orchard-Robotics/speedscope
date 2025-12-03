# -------- Base builder image --------
FROM node:20-alpine AS builder

RUN apk add --no-cache bash git

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

COPY . .

# Handle file ownership uncertainties
RUN git config --global --add safe.directory /app

# Build release artifacts into dist/release using the existing script
RUN npm run prepack

# -------- Production runtime image --------
FROM nginx AS runner

WORKDIR /app

# Copy built artifacts and CLI entrypoint from builder
COPY --from=builder /app/dist/release /usr/share/nginx/html
