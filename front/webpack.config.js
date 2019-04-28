const path = require('path');

var utils = {
  osx: '../javascript/utils.js',
  chrome: '../chrome_extension/js/utils.js'
};

module.exports = {
  mode: 'none',
  entry: [utils[process.env.TARGET || 'osx'], '../javascript/main.jsx'],
  devtool: 'source-map',
  output: {
    publicPath: 'public/',
    path: __dirname + '/public',
    filename: 'bundle.js'
  },
  module: {
    rules: [
      { test: /\.jsx$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          presets: [
            "@babel/preset-env",
            "@babel/preset-react"
          ]
        }
      },
      {test: /\.styl$/, loader: 'style-loader!css-loader!stylus-loader'},
      {test: /\.ttf$/, loader: 'file-loader' }
    ]
  },
  resolve: {
    extensions: ['.js', '.jsx', '.styl']
  }
};
