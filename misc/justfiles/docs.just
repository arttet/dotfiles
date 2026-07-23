docs_dir := justfile_directory() / env("DOCS_DIR", "docs")
docs_port := env("DOCS_PORT", "5173")

[doc('Install dependencies')]
[working-directory(docs_dir)]
install:
    @echo "✨ Installing Dependencies..."
    bun install --frozen-lockfile
    @echo "✅ Documentation dependencies finished installing"

[doc('Update dependencies')]
[working-directory(docs_dir)]
update:
    @echo "✨ Updating Dependencies..."
    bun update --interactive
    @echo "✅ Documentation dependencies finished updating"

[doc('Audit dependencies')]
[working-directory(docs_dir)]
audit:
    @echo "🔍 Auditing dependencies..."
    bun audit
    @echo "✅ Audit complete!"

[doc('Serve docs')]
[working-directory(docs_dir)]
dev:
    @echo "🚀 Starting development server on port {{ docs_port }}..."
    bun run docs:dev --port {{ docs_port }}

[doc('Build docs')]
[working-directory(docs_dir)]
build:
    @echo "🏗️ Building documentation..."
    bun run docs:build
    @echo "✅ Build complete!"

[doc('Preview docs')]
[working-directory(docs_dir)]
preview:
    @echo "👀 Starting preview server on port {{ docs_port }}..."
    bun run docs:preview --port {{ docs_port }}

[doc('Clean build artifacts and cache')]
[working-directory(docs_dir)]
clean:
    @echo "🧹 Sweeping documentation artifacts..."
    rm -rf node_modules .vitepress/cache .vitepress/dist
