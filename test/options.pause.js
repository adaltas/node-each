import each from "../lib/index.js";

describe("options.pause", function () {
  it("each resolves on resume", function () {
    const stack = [];
    const scheduler = each({ pause: true });
    scheduler.then(() => {
      stack.push(1);
    });
    return new Promise((resolve) => {
      setTimeout(async () => {
        stack.length.should.eql(0);
        await scheduler.resume();
        stack.length.should.eql(1);
        resolve();
      }, 10);
    });
  });

  it("call resolve on resume", function () {
    const stack = [];
    const scheduler = each({ pause: true });
    scheduler.call(
      () =>
        new Promise((resolve) => {
          stack.push(1);
          resolve(1);
        }),
    );
    scheduler.call(
      () =>
        new Promise((resolve) => {
          stack.push(2);
          resolve(2);
        }),
    );
    return new Promise((resolve) => {
      setTimeout(async () => {
        stack.length.should.eql(0);
        await scheduler.resume();
        stack.length.should.eql(2);
        resolve();
      }, 50);
    });
  });

  it("resume resolves scheduled item when paused", function () {
    const stack = [];
    const eacher = each({ pause: true });
    eacher.call([1, 2]).then(() => {
      stack.push(2);
    });
    eacher.then(() => {
      stack.push(1);
    });
    return new Promise((resolve) => {
      setTimeout(async () => {
        await eacher.resume();
        stack.should.eql([1, 2]);
        resolve();
      }, 20);
    });
  });
});
