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
    const result = await each(
      [item(1, 40), item(2, 20), item(3, 50), item(4, 10)],
      2,
    );
    result.should.eql([1, 2, 3, 4]);
    stacks.start.should.eql([1, 2, 3, 4]);
    stacks.end.should.eql([2, 1, 4, 3]);
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
      each: await each(
        [item(1, 20), item(2, 40), item(3, 10), item(4, 30)],
        true,
      ),
      all: await Promise.all([
        item(1, 20),
        item(2, 40),
        item(3, 10),
        item(4, 30),
      ]),
    };
    result.each.should.eql(result.all);
  });

  it("empty array", async function () {
    let count = 0;
    await each([], 4, () => {
      count++;
    });
    count.should.eql(0);
  });

  it("promise handler with multiple items", async function () {
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
      4,
      (item, index) => {
        return new Promise((resolve) => {
          index.should.eql(count);
          count++;
          item.id.should.eql(count);
          setTimeout(resolve, 20);
        });
      },
    );
    count.should.eql(9);
  });

  it("promise handler with one item", async function () {
    let count = 0;
    await each([{ id: 1 }], 4, (item, index) => {
      return new Promise((resolve) => {
        index.should.eql(count);
        count++;
        item.id.should.eql(count);
        setTimeout(resolve, 20);
      });
    });
    count.should.eql(1);
  });

  it("sync handler", async function () {
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
      4,
      (item, index) => {
        index.should.eql(count);
        count++;
        item.id.should.eql(count);
      },
    );
    count.should.eql(9);
  });

  it("item sync functions", async function () {
    let count = 0;
    const test = () => count++;
    await each([test, test, test, test, test, test, test, test, test], 4);
    count.should.eql(9);
  });

  it("item async functions returning a promise", async function () {
    let count = 0;
    let running = 0;
    const test = () => {
      running++;
      running.should.be.above(0);
      running.should.be.below(5);
      return new Promise((resolve) => {
        running.should.be.above(0);
        running.should.be.below(5);
        count++;
        setTimeout(() => {
          running.should.be.above(0);
          running.should.be.below(5);
          running--;
          resolve();
        }, 20);
      });
    };
    await each([test, test, test, test, test, test, test, test, test], 4);
    count.should.eql(9);
    running.should.eql(0);
  });

  it("handler with error thrown", async function () {
    let count = 0;
    const test = () => {
      count++;
      if (count === 6) throw new Error("catchme");
      return new Promise((resolve) => {
        setTimeout(resolve, 20);
      });
    };
    try {
      await each([test, test, test, test, test, test, test, test, test], 4);
    } catch (error) {
      error.message.should.eql("catchme");
    } finally {
      count.should.eql(6);
    }
  });

  it("handler with error rejected", async function () {
    let count = 0;
    const test = () => {
      return new Promise((resolve, reject) => {
        setTimeout(() => {
          count.should.be.below(6);
          count++;
          if (count >= 4) {
            reject(new Error("catchme"));
          } else {
            resolve();
          }
        }, 20);
      });
    };
    try {
      await each([test, test, test, test, test, test, test, test, test], 3);
    } catch (error) {
      error.message.should.eql("catchme");
    } finally {
      count.should.eql(4);
    }
  });
});
