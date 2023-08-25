/** @type {import('tailwindcss').Config} */
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
    extend: {},
  },
  plugins: [
    require(`@tailwindcss/forms`),
    require(`@tailwindcss/typography`)
  ],
}
