
import eslint from '@rollup/plugin-eslint';
import pkg from './package.json' assert { type: 'json' }

export default {
  input: 'lib/index.js',
  output: [
    {
      file: `dist/${pkg.name}.umd.js`,
      name: 'mixme',
      format: 'umd'
    },
    {
      file: `dist/${pkg.name}.cjs.cjs`,
      format: 'cjs'
    },
    {
      file: `dist/${pkg.name}.esm.js`,
      format: 'esm'
    }
  ],
  plugins: [eslint({
    fix: true,
  })]
};
