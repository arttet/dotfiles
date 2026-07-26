docs_dir := justfile_directory() / env("DOCS_DIR", "docs")
docs_port := env("DOCS_PORT", "5173")

[doc('Install dependencies')]
[working-directory(docs_dir)]
install:
    @echo "✨ Installing Dependencies..."
    aube install --frozen-lockfile
    @echo "✅ Documentation dependencies finished installing"

[doc('Update dependencies')]
[working-directory(docs_dir)]
update:
    @echo "✨ Updating Dependencies..."
    aube update --interactive
    @echo "✅ Documentation dependencies finished updating"

[doc('Audit dependencies')]
[working-directory(docs_dir)]
audit:
    @echo "🔍 Auditing dependencies..."
    aube audit
    @echo "✅ Audit complete!"

[doc('Serve docs')]
[working-directory(docs_dir)]
dev:
    @echo "🚀 Starting development server on port {{ docs_port }}..."
    aube run docs:dev -- --port {{ docs_port }}

[doc('Build docs')]
[working-directory(docs_dir)]
build:
    @echo "🏗️ Building documentation..."
    aube run docs:build
    @echo "✅ Build complete!"

[doc('Preview docs')]
[working-directory(docs_dir)]
preview:
    @echo "👀 Starting preview server on port {{ docs_port }}..."
    aube run docs:preview -- --port {{ docs_port }}

[doc('Clean build artifacts and cache')]
[working-directory(docs_dir)]
clean:
    @echo "🧹 Sweeping documentation artifacts..."
    rm -rf .vitepress/cache node_modules dist
    @echo "✅ Documentation artifacts swept"

[doc('Pack package archive')]
[working-directory(docs_dir)]
pack:
    @echo "📦 Packing documentation package..."
    aube pack
    @echo "✅ Pack complete!"
