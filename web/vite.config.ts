import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

import tsconfigPaths from "vite-tsconfig-paths";

// https://vitejs.dev/config/
export default defineConfig({
	plugins: [react(), tsconfigPaths()],
	base: "./",
	build: {
		outDir: "build",
		minify: false,
	},
	server: {
		host: "127.0.0.1",
		port: 1235,
	},
});
