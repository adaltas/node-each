import each from "../lib/index.js";
import fs from "fs";
import path from "path";
import { exec } from "child_process";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const dir = path.resolve(__dirname, "../samples");
const samples = fs.readdirSync(dir);

describe("Samples", function () {
  /* eslint mocha/no-setup-in-describe: "off" */
  each(samples, true, function (sample) {
    if (!/\.js$/.test(sample)) return;
    it(`Sample ${sample}`, function (callback) {
      exec(`node ${path.resolve(dir, sample)}`, (err) => {
        callback(err);
      });
    });
  });
});
