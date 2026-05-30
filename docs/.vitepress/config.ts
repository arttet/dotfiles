import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: "/dotfiles/",
  srcDir: "content",

  title: "My dotfiles",
  description: "My dotfiles",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: "Home", link: "/" },
      { text: "User Guide", link: "/user-guide/getting-started/introduction" },
    ],

    sidebar: [
      {
        text: "User Guide",
        collapsed: false,
        items: [
          { text: "Getting Started", link: "/user-guide/getting-started/introduction" },
        ],
      },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/arttet/dotfiles" },
    ],
  },

  vite: {
    build: {
      minify: "oxc",
      target: "es2022",
      cssCodeSplit: true,
      rollupOptions: {
        onLog(level, log, handler) {
          if (log.code === "INVALID_ANNOTATION" && log.id?.includes("node_modules/@vueuse/core/")) {
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
