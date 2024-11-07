import eslint from "@rollup/plugin-eslint";
import { readFile } from "node:fs/promises";
const pkg = JSON.parse(
  await readFile(new URL("./package.json", import.meta.url), "utf8"),
);

export default {
  input: "lib/index.js",
  output: [
    {
      file: `dist/${pkg.name}.umd.js`,
      name: "mixme",
      format: "umd",
    },
    {
      file: `dist/${pkg.name}.cjs.cjs`,
      format: "cjs",
    },
    {
      file: `dist/${pkg.name}.esm.js`,
      format: "esm",
    },
  ],
  plugins: [
    eslint({
      fix: true,
    }),
  ],
};
