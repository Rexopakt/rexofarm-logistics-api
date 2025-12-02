FROM node:18-alpine AS builder

WORKDIR /var/www/app

# Install git for dependencies
RUN apk add --no-cache git

# Copy package files
COPY package*.json ./

# Install all dependencies
RUN npm install --quiet --legacy-peer-deps

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:18-alpine AS production

WORKDIR /var/www/app

# Install git for production dependencie
RUN apk add --no-cache git

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm install --quiet --only=production --legacy-peer-deps && npm cache clean --force

# Copy built application from builder stage
COPY --from=builder /var/www/app/dist ./dist

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nestjs -u 1001
USER nestjs

EXPOSE 3000

CMD [ "node", "dist/main" ]