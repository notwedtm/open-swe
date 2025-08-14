# Multi-stage build for Open SWE LangGraph Agent
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Install Yarn
RUN corepack enable && corepack prepare yarn@3.5.1 --activate

# Copy package files
COPY package.json yarn.lock .yarnrc.yml ./
COPY packages/shared/package.json ./packages/shared/
COPY apps/open-swe/package.json ./apps/open-swe/

# Install dependencies
RUN yarn install --immutable

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app

# Install Yarn
RUN corepack enable && corepack prepare yarn@3.5.1 --activate

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/.yarn ./.yarn

# Copy source code
COPY . .

# Build the shared package first (required dependency)
RUN yarn workspace @open-swe/shared build

# Build the agent application
RUN yarn workspace @open-swe/agent build

# Production image, copy all the files and run the application
FROM base AS runner
WORKDIR /app

# Install Yarn
RUN corepack enable && corepack prepare yarn@3.5.1 --activate

# Create a non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 agent

# Copy built application
COPY --from=builder --chown=agent:nodejs /app/apps/open-swe/dist ./apps/open-swe/dist
COPY --from=builder --chown=agent:nodejs /app/packages/shared/dist ./packages/shared/dist
COPY --from=builder --chown=agent:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=agent:nodejs /app/.yarn ./.yarn
COPY --from=builder --chown=agent:nodejs /app/package.json ./
COPY --from=builder --chown=agent:nodejs /app/yarn.lock ./
COPY --from=builder --chown=agent:nodejs /app/.yarnrc.yml ./
COPY --from=builder --chown=agent:nodejs /app/packages/shared/package.json ./packages/shared/
COPY --from=builder --chown=agent:nodejs /app/apps/open-swe/package.json ./apps/open-swe/
COPY --from=builder --chown=agent:nodejs /app/langgraph.json ./

USER agent

# Expose port
EXPOSE 2024

# Set environment variables
ENV NODE_ENV=production
ENV PORT=2024

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:2024/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Start the application using LangGraph
CMD ["yarn", "workspace", "@open-swe/agent", "dev"]
