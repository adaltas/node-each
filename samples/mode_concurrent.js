import assert from "assert";
import each from "../lib/index.js";

let running = 0;
const result = await each(
  [{ id: "a" }, { id: "b" }, { id: "c" }, { id: "d" }],
  2,
  function (item, index) {
    running++;
    if (running > 2) {
      throw Error("At most 2 running tasks");
    }
    return new Promise((resolve, reject) =>
      setTimeout(() => {
        running--;
        if (running > 2) {
          reject(Error("At most 2 running tasks"));
        } else {
          resolve(`${item.id}@${index}`);
        }
      }, 100),
    );
  },
);

assert.deepStrictEqual(result, ["a@0", "b@1", "c@2", "d@3"]);
