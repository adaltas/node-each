import each from "../lib/index.js";

describe("api.normalize", function () {
  it("validation", function () {
    (() => {
      each(new Promise(() => {}));
    }).should.throw(
      "Invalid argument: argument at position 0 must be one of array, object, function, boolean or number, got {}",
    );
  });

  it("0 arg, is a promise", function () {
    each().should.be.a.Promise();
  });

  it("multi args, merge items", async function () {
    const result = await each([1, 2, 3], [4, 5, 6]);
    result.should.eql([1, 2, 3, 4, 5, 6]);
  });

  it("multi args, merge options", async function () {
    const eacher = each(2, () => {}, { relax: true });
    await eacher.options("concurrency").should.be.resolvedWith(2);
    await eacher.options("pause").should.be.resolvedWith(false);
    await eacher.options("handler").should.be.resolvedWith(() => {});
    await eacher.options("relax").should.be.resolvedWith(true);
  });

  it("1 arg, accept `items` argument", async function () {
    await each([]);
  });

  it("1 arg, accept `option` argument", async function () {
    await (async () => {
      const e = each(true);
      e.options("concurrency").should.be.resolvedWith(-1);
      await e;
    })();
    await (async () => {
      const e = each(2);
      e.options("concurrency").should.be.resolvedWith(2);
      await e;
    })();
  });

  it("2 args, accept `items, concurrency` argument", async function () {
    await (async () => {
      const e = each([], true);
      e.options("concurrency").should.be.resolvedWith(-1);
      await e;
    })();
    await (async () => {
      const e = each([], 2);
      e.options("concurrency").should.be.resolvedWith(2);
      await e;
    })();
  });

  it("2 args, accept `items, handler` argument", function () {
    each([], () => 42)
      .options("handler")
      .then((handler) => {
        handler().should.equal(42);
      });
  });

  it("3 args, accept `items, concurrency, handler` argument", async function () {
    await (async () => {
      const e = each([], true, () => 42);
      await e.options("concurrency").should.be.resolvedWith(-1);
      await e.options("handler").then((handler) => {
        handler().should.equal(42);
      });
      await e;
    })();
    await (async () => {
      const e = each([], 2, () => 42);
      await e.options("concurrency").should.be.resolvedWith(2);
      await e.options("handler").then((handler) => {
        handler().should.equal(42);
      });
      await e;
    })();
  });

  it("3 args, accept `items, handler, concurrency` argument", async function () {
    await (async () => {
      const e = each([], () => 42, true);
      await e.options("concurrency").should.be.resolvedWith(-1);
      await e.options("handler").then((handler) => {
        handler().should.equal(42);
      });
      await e;
    })();
    await (async () => {
      const e = each([], () => 42, 2);
      await e.options("concurrency").should.be.resolvedWith(2);
      await e.options("handler").then((handler) => {
        handler().should.equal(42);
      });
      await e;
    })();
  });
});
