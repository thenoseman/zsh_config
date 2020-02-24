module.exports = {
  extends: ["eslint:recommended"],
  parserOptions: { ecmaVersion: 8 },
  env: {
    browser: true,
    es6: true,
  },
  globals: {
    module: true,
    chrome: true,
    Promise: true,
    console: true,
    exports: true,
  },
};
