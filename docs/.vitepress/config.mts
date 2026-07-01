import { defineConfig } from "vitepress";
import llmstxt, { copyOrDownloadAsMarkdownButtons } from "vitepress-plugin-llms";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Dotfiles",
  description: "Secure. Fast. Modern.",
  head: [["meta", { name: "theme-color", content: "#6366f1" }]],

  srcDir: "src",
  base: process.env.CI_BASE_URL || "/",
  cleanUrls: true,

  markdown: {
    theme: {
      light: "catppuccin-latte",
      dark: "catppuccin-mocha",
    },
    config(md) {
      md.use(copyOrDownloadAsMarkdownButtons);
    },
  },

  vite: {
    plugins: [llmstxt()],
    build: {
      minify: "oxc",
      target: "es2022",
      rolldownOptions: {
        onLog(level, log, defaultHandler) {
          if (
            log.code === "INVALID_ANNOTATION"
            && log.id?.includes("node_modules/@vueuse/core/")
          ) {
            return;
          }

          defaultHandler(level, log);
        },
      },
    },

    ssr: {
      noExternal: ["vitepress"],
    },
  },

  themeConfig: {
    siteTitle: "Dotfiles",
    logo: "/logo.svg",
    socialLinks: [
      { icon: "github", link: "https://github.com/arttet/dotfiles" },
    ],

    search: {
      provider: "local",
    },

    outline: {
      level: [2, 3],
    },

    nav: [
      { text: "Home", link: "/" },
      { text: "Guide", link: "/guide/" },
      { text: "Cheatsheet", link: "/cheatsheet" },
      { text: "Architecture", link: "/architecture" },
      {
        text: "Tools",
        items: [
          { text: "Terminals", link: "/terminals/overview" },
          { text: "Editors", link: "/editors/neovim" },
          { text: "Multiplexers", link: "/multiplexers/zellij" },
          { text: "CLI", link: "/cli/yazi" },
          { text: "AI Agents", link: "/ai/" },
          { text: "WM", link: "/wm/hyprland" },
        ],
      },
    ],

    sidebar: [
      {
        text: "Reference",
        collapsed: false,
        items: [
          { text: "Hotkey Cheatsheet", link: "/cheatsheet" },
          { text: "Terminal Stack", link: "/terminals/overview" },
          { text: "AI Agents", link: "/ai/" },
        ],
      },
      {
        text: "Introduction",
        collapsed: false,
        items: [
          { text: "Getting Started", link: "/guide/" },
          { text: "Architecture", link: "/architecture" },
          { text: "Performance", link: "/performance" },
        ],
      },
      {
        text: "Editors",
        collapsed: false,
        items: [
          { text: "Neovim", link: "/editors/neovim" },
          { text: "Helix", link: "/editors/helix" },
        ],
      },
      {
        text: "Multiplexers",
        collapsed: false,
        items: [
          { text: "Zellij", link: "/multiplexers/zellij" },
          { text: "Tmux", link: "/multiplexers/tmux" },
          { text: "Herdr", link: "/multiplexers/herdr" },
        ],
      },
      {
        text: "CLI & Shell",
        collapsed: false,
        items: [
          { text: "Nushell", link: "/cli/nushell" },
          { text: "Yazi", link: "/cli/yazi" },
        ],
      },
      {
        text: "Window Management",
        collapsed: false,
        items: [{ text: "Hyprland", link: "/wm/hyprland" }],
      },
    ],

    footer: {
      message: "Platform Documentation",
      copyright: "Copyright © 2026 Artyom Tetyukhin",
    },
  },
});
