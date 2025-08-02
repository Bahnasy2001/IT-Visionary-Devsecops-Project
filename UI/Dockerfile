# ---------- Stage 1: build ----------
FROM node:24-alpine AS build

WORKDIR /app

# Copy only package.json + package-lock.json first (use cache for faster builds)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the source code
COPY . .

# ---------- Stage 2: Runner ----------
FROM node:24-alpine

WORKDIR /app

# Copy only needed files from build stage
COPY --from=build /app .

# Expose the port your app uses (from index.js)
EXPOSE 3000

# Recommended: direct node command (simpler & faster in production)
# Start the application
CMD ["node", "app.js"]