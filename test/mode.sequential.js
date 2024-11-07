import each from "../lib/index.js";

describe("mode.sequential", function () {
  it("list of functions", async function () {
    const stacks = { start: [], end: [] };
    const item = (index, timeout) => () => {
      stacks.start.push(index);
      return new Promise((resolve) =>
        setTimeout(() => {
          stacks.end.push(index);
          resolve(index);
        }, timeout),
      );
    };
    const result = await each([item(1, 20), item(2, 10)], 1);
    result.should.eql([1, 2]);
    stacks.start.should.eql([1, 2]);
    stacks.end.should.eql([1, 2]);
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
      each: await each([item(1, 20), item(2, 10)], 1),
      all: await Promise.all([item(1, 20), item(2, 10)]),
    };
    result.each.should.eql(result.all);
  });

  it("promise handler with multiple items", async function () {
    let count = 0;
    let running = 0;
    await each(
      [
        { id: 1 },
        { id: 2 },
        { id: 3 },
        { id: 4 },
        { id: 5 },
        { id: 6 },
        { id: 7 },
        { id: 8 },
        { id: 9 },
      ],
      () => {
        count++;
        running++;
        running.should.eql(1);
        return new Promise((resolve) => {
          running.should.eql(1);
          setTimeout(() => {
            running.should.eql(1);
            running--;
            resolve();
          }, 20);
        });
      },
    );
    count.should.eql(9);
  });

  it("sync handler with multiple items", async function () {
    let count = 0;
    await each(
      [
        { id: 1 },
        { id: 2 },
        { id: 3 },
        { id: 4 },
        { id: 5 },
        { id: 6 },
        { id: 7 },
        { id: 8 },
        { id: 9 },
      ],
      (item, index) => {
        index.should.eql(index);
        count++;
        item.id.should.eql(count);
      },
    );
    count.should.eql(9);
  });
});
