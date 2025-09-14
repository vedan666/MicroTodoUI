# Build stage
FROM node:16-alpine as build

# Create non-root user for build stage
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy package files and install dependencies as root (required for some packages)
COPY package*.json ./
RUN npm install

# Copy source files and set ownership
COPY . .
RUN chown -R appuser:appgroup /app

# Switch to non-root user for build
USER appuser
RUN npm run build

# Production stage
FROM nginx:alpine

# Create non-root user for nginx
RUN addgroup -S nginxgroup && adduser -S nginxuser -G nginxgroup

# Copy nginx configuration and static files
COPY --from=build /app/build /usr/share/nginx/html
RUN chown -R nginxuser:nginxgroup /usr/share/nginx/html

# Switch to non-root user
USER nginxuser

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]