import each from "../lib/index.js";

describe("api.pause", function () {
  it("call pause after initialisation does not resolve", function () {
    let count = 0;
    const scheduler = each(["a", "b", "c"]);
    scheduler.pause();
    setTimeout(() => {
      count++;
      scheduler.end();
    }, 50);
    return scheduler.then((items) => {
      count.should.eql(1);
      items.should.eql(["a", "b", "c"]);
    });
  });

  it("timing", async function () {
    const stack = [];
    const scheduler = each();
    const prom1 = scheduler.call(() => {
      return new Promise((resolve) => {
        stack.push(1);
        resolve(1);
      });
    });
    const prom2 = scheduler.call(() => {
      return new Promise((resolve) => {
        stack.push(2);
        resolve(2);
      });
    });
    scheduler.pause();
    const prom3 = scheduler.call(() => {
      return new Promise((resolve) => {
        stack.push(3);
        resolve(3);
      });
    });
    stack.length.should.eql(0);
    setTimeout(() => {
      stack.length.should.eql(0);
      scheduler.resume();
    }, 50);
    await Promise.all([prom1, prom2, prom3]);
    stack.length.should.eql(3);
  });
});
