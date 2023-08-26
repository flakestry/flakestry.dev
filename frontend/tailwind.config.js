/** @type {import('tailwindcss').Config} */

const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    "./src/**/*.{js,elm,ts,css,html}",
    "./.elm-land/**/*.{js,elm,ts,css,html}"
  ],
  theme: {
    container: {
      center: true,
      padding: '2rem',
    },
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require(`@tailwindcss/forms`),
    require(`@tailwindcss/typography`)
  ],
}
