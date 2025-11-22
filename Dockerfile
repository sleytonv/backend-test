# ===== STAGE 1: BUILD =====
FROM node:18-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build    # genera dist/

# ===== STAGE 2: RUNTIME =====
FROM node:18-alpine
WORKDIR /app

COPY --from=build /app/dist ./dist
COPY package*.json ./
RUN npm ci --omit=dev

EXPOSE 4000
CMD ["npm", "run", "start:prod"]

