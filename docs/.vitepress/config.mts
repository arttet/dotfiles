import { defineConfig } from "vitepress";
import llmstxt, { copyOrDownloadAsMarkdownButtons } from "vitepress-plugin-llms";

declare const process: { env: Record<string, string | undefined> };

const nav = [
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
];

const sidebar = [
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
    text: "Hotkeys",
    collapsed: false,
    items: [{ text: "Cheatsheet", link: "/cheatsheet" }],
  },
  {
    text: "Terminals",
    collapsed: false,
    items: [{ text: "Terminal Stack", link: "/terminals/overview" }],
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
    text: "AI Agents",
    collapsed: false,
    items: [{ text: "Overview", link: "/ai/" }],
  },
  {
    text: "Window Management",
    collapsed: false,
    items: [{ text: "Hyprland", link: "/wm/hyprland" }],
  },
];

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: process.env.CI_BASE_URL || "/",
  srcDir: "src",

  title: "Dotfiles",
  description: "Secure. Fast. Modern.",

  head: [["meta", { name: "theme-color", content: "#6366f1" }]],

  markdown: {
    theme: {
      light: "github-light",
      dark: "github-dark",
    },
    config(md) {
      md.use(copyOrDownloadAsMarkdownButtons);
    },
  },

  themeConfig: {
    logo: "/logo.svg",
    siteTitle: "Dotfiles",

    nav,
    sidebar,

    search: {
      provider: "local",
    },

    outline: {
      level: [2, 3],
    },

    socialLinks: [
      { icon: "github", link: "https://github.com/arttet/dotfiles" },
    ],

    footer: {
      message: "Platform Documentation",
      copyright: "Copyright © 2026 Artyom Tetyukhin",
    },
  },

  vite: {
    plugins: [llmstxt()],
    build: {
      minify: "oxc",
      target: "es2022",
      rollupOptions: {
        onLog(level, log, handler) {
          if (
            log.code === "INVALID_ANNOTATION"
            && log.id?.includes("node_modules/@vueuse/core/")
          ) {
            return;
          }

          handler(level, log);
        },
      },
    },

    ssr: {
      noExternal: ["vitepress"],
    },
  },

  cleanUrls: true,
});
