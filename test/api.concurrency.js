import each from "../lib/index.js";

describe("api.concurrency", function () {
  it("pump itself when called alone", function () {
    return each().concurrency(2).concurrency().should.resolvedWith(2);
  });

  it("from parallel to sequential", async function () {
    const history = [];
    const handler = (id) => {
      history.push(`${id}:start`);
      return new Promise((resolve) => {
        setTimeout(() => {
          history.push(`${id}:end`);
          resolve();
        }, 20);
      });
    };
    await each(-1)
      .call(() => handler(1))
      .call(() => handler(2))
      .call(() => handler(3))
      .concurrency(1)
      .call(() => handler(4))
      .call(() => handler(5))
      .call(() => handler(6));
    history.should.eql([
      "1:start",
      "2:start",
      "3:start",
      "1:end",
      "2:end",
      "3:end",
      "4:start",
      "4:end",
      "5:start",
      "5:end",
      "6:start",
      "6:end",
    ]);
  });

  it("from sequential to parallel", async function () {
    const history = [];
    const handler = (id) => {
      history.push(`${id}:start`);
      return new Promise((resolve) => {
        setTimeout(() => {
          history.push(`${id}:end`);
          resolve();
        }, 20);
      });
    };
    await each(-1)
      .concurrency(1)
      .call(() => handler(1))
      .call(() => handler(2))
      .call(() => handler(3))
      .concurrency(-1)
      .call(() => handler(4))
      .call(() => handler(5))
      .call(() => handler(6));
    history.should.eql([
      "1:start",
      "1:end",
      "2:start",
      "2:end",
      "3:start",
      "3:end",
      "4:start",
      "5:start",
      "6:start",
      "4:end",
      "5:end",
      "6:end",
    ]);
  });
});
