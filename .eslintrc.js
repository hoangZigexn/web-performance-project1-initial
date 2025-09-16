module.exports = {
  env: {
    browser: true,
    node: true,
    es2020: true,
    jest: true
  },
  extends: [
    'eslint:recommended'
  ],
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'script'
  },
  rules: {
    'no-unused-vars': 'warn',
    'no-console': 'off'
  },
  overrides: [
    {
      files: ['**/*.test.js', '**/*.spec.js', '**/setupTests.js'],
      env: {
        jest: true
      }
    }
  ]
};
