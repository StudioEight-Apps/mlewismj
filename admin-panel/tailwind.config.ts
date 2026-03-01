import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        whisper: {
          gold: '#C4A574',
          dark: '#1A1A1A',
          cream: '#F5F2EE',
          muted: '#9A9A9A',
        },
      },
    },
  },
  plugins: [],
};

export default config;
