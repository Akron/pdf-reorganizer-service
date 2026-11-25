// vite.config.js
import { resolve } from 'node:path'

/// <reference types="vitest" />
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    lib: {
      // Could also be a dictionary or array of multiple entry points
      entry: resolve(import.meta.dirname, 'src/pdf-dropper.js'),
      name: 'Reorganizer',
      formats: ['es'],
      // the proper extensions will be added
      fileName: 'reorganizer',
    },
    outDir: "build",
    minify : "oxc",
    rollupOptions: {
    },
  },
  test: {
    environment: 'happy-dom',
  }
});
