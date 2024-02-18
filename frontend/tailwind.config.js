/** @type {import('tailwindcss').Config} */

const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    "./src/**/*.{js,elm,ts,css,html,mts}",
    "./.elm-land/**/*.{js,elm,ts,css,html}"
  ],
  theme: {
    container: {
      center: true,
    },
    
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        primary: colors.blue,
        secondary: colors.yellow,
        neutral: colors.gray,
      },
    },
  },
  plugins: [
    require(`@tailwindcss/forms`),
    require(`@tailwindcss/typography`)
  ],
}
