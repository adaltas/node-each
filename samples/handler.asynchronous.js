import assert from "assert";
import each from "../lib/index.js";

const result = await each(
  [{ id: "a" }, { id: "b" }, { id: "c" }, { id: "d" }],
  (item, index) =>
    new Promise((resolve) => setTimeout(resolve(`${item.id}@${index}`), 100)),
);

assert.deepStrictEqual(result, ["a@0", "b@1", "c@2", "d@3"]);
