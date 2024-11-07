import each from "../lib/index.js";

describe("api.handler", function () {
  it("handle a scalar value", async function () {
    const result = await each([2, 4, 6], (i) => i + 1);
    result.should.eql([3, 5, 7]);
  });

  it("handle a function", async function () {
    const result = await each(
      [
        () => "a",
        () => new Promise((resolve) => resolve("b")),
        () => new Promise((resolve) => setImmediate(() => resolve("c"))),
      ],
      async (i) => {
        return `> ${await i.call()}`;
      },
    );
    result.should.eql(["> a", "> b", "> c"]);
  });

  it("handle promises", async function () {
    const result = await each(
      [
        new Promise((resolve) => resolve("a")),
        new Promise((resolve) => setImmediate(() => resolve("b"))),
      ],
      async (i) => {
        return `> ${await i}`;
      },
    );
    result.should.eql(["> a", "> b"]);
  });
});
