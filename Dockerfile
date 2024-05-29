FROM node:20.14.0-bookworm-slim AS deps
ENV NODE_ENV=development
WORKDIR /app
COPY package.json package-lock.json /app
RUN npm ci

FROM node:20.14.0-bookworm-slim AS builder
ENV NEXT_TELEMETRY_DISABLED=1
WORKDIR /app
COPY . /app
COPY --from=deps /app/node_modules /app/node_modules
RUN npm run build

FROM gcr.io/distroless/nodejs20-debian12:nonroot
ENV NODE_ENV=production
WORKDIR /app
COPY --from=builder /app/.next/standalone /app
COPY --from=builder /app/.next/static /app/public/_next/static
CMD ["/app/server.js"]
