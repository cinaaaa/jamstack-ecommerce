FROM node:14-alpine AS builder
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY . .
RUN yarn
ENV NEXT_TELEMETRY_DISABLED 1
RUN npx prisma generate
RUN npx prisma push-db
RUN npx prisma seed-db
RUN yarn build
RUN mkdir -p /app/.next/cache/images
# Production image, copy all the files and run next
FROM node:14-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
COPY --chown=nextjs:nodejs --from=builder /app/ ./
USER nextjs
ENV PORT 3000
CMD ["npm", "run","start"]