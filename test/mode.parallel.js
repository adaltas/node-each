import each from "../lib/index.js";

describe("mode.concurrent", function () {
  it("list of functions", async function () {
    const stacks = { start: [], end: [] };
    const item = (index, timeout) => () => {
      stacks.start.push(index);
      return new Promise((resolve) =>
        setTimeout(() => {
          stacks.end.push(index) && resolve(index);
        }, timeout),
      );
    };
    const result = await each([item(1, 20), item(2, 40), item(3, 10)], true);
    result.should.eql([1, 2, 3]);
    stacks.start.should.eql([1, 2, 3]);
    stacks.end.should.eql([3, 1, 2]);
  });

  it("ordered like Promise.all", async function () {
    const item = (index, timeout) => {
      return new Promise((resolve) =>
        setTimeout(() => {
          resolve(index);
        }, timeout),
      );
    };
    const result = {
      each: await each([item(1, 20), item(2, 40), item(3, 10)], true),
      all: await Promise.all([item(1, 20), item(2, 40), item(3, 10)]),
    };
    result.each.should.eql(result.all);
  });

  it("promise handler with multiple items", async function () {
    let count = 0;
    await each([{ id: 1 }, { id: 2 }, { id: 3 }], true, (item, index) => {
      return new Promise((resolve) => {
        index.should.eql(count);
        count++;
        item.id.should.eql(count);
        setTimeout(resolve, 100);
      });
    });
    count.should.eql(3);
  });

  it("handle very large array", async function () {
    let count = 0;
    const values = Array.from({ length: Math.pow(2, 14) + 1 }, () =>
      Math.random(),
    );
    await each(values, true, () => {
      return new Promise((resolve) => {
        count++;
        setTimeout(resolve, 1);
      });
    });
    count.should.eql(values.length);
  });

  it("item sync functions", async function () {
    let count = 0;
    let running = 0;
    const test = () => {
      running++;
      running.should.be.above(0);
      running.should.be.below(10);
      return new Promise((resolve) => {
        running.should.be.above(0);
        running.should.be.below(10);
        count++;
        setTimeout(() => {
          running.should.be.above(0);
          running.should.be.below(10);
          running--;
          resolve();
        }, 20);
      });
    };
    await each([test, test, test, test, test, test, test, test, test], true);
    count.should.eql(9);
    running.should.eql(0);
  });
});
