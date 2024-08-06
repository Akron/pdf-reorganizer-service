// vite.config.js
import { resolve } from 'path'

/// <reference types="vitest" />
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    lib: {
      // Could also be a dictionary or array of multiple entry points
      entry: resolve(__dirname, 'src/pdf-dropper.js'),
      name: 'Reorganizer',
      formats: ['es'],
      // the proper extensions will be added
      fileName: 'reorganizer',
    },
    outDir: "build",
    minify : "esbuild",
    rollupOptions: {
    },
  },
  test: {
    environment: 'happy-dom',
  }
});
