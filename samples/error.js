import assert from "assert";
import each from "each";

try {
  await each(2).call([
    () => new Promise((resolve) => setImmediate(() => resolve("ok"))),
    () =>
      new Promise((resolve, reject) =>
        setImmediate(() => reject(Error("Catchme")))
      ),
    () => new Promise((resolve) => setImmediate(() => resolve("ok"))),
  ]);
} catch (error) {
  assert.equal(error.message, "Catchme");
}
