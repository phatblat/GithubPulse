module.exports = {
  plugins: [
    ['@babel/plugin-proposal-class-properties', { loose: true }],
  ],
  presets: [
    "@babel/preset-env",
    "@babel/preset-react",
  ],
};
