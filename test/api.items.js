import each from "../lib/index.js";

describe("api.items", function () {
  describe("values", function () {
    it("pass an empty list", async function () {
      // Constructor
      let result = await each([]);
      result.should.eql([]);
      // Push
      result = await each().call([]);
      result.should.eql([]);
    });

    it("pass a value", async function () {
      // Constructor
      let result = await each(["ok"]);
      result.should.eql(["ok"]);
      // Push
      result = await each().call(["ok"]);
      result.should.eql(["ok"]);
    });

    it("pass a function which return a value", async function () {
      // Constructor
      let result = await each([() => "ok"]);
      result.should.eql(["ok"]);
      // Push
      result = await each().call([() => "ok"]);
      result.should.eql(["ok"]);
    });
  });

  describe("functions", function () {
    it("pass a function which return a promise which resolves immediatly", async function () {
      // Constructor
      let result = await each([() => new Promise((resolve) => resolve("ok"))]);
      result.should.eql(["ok"]);
      // Push
      result = await each().call([
        () => new Promise((resolve) => resolve("ok")),
      ]);
      result.should.eql(["ok"]);
    });

    it("pass a function which return a promise which resolves in next tick", async function () {
      // Constructor
      let result = await each([
        () => new Promise((resolve) => setImmediate(() => resolve("ok"))),
      ]);
      result.should.eql(["ok"]);
      // Push
      result = await each().call([
        () => new Promise((resolve) => setImmediate(() => resolve("ok"))),
      ]);
      result.should.eql(["ok"]);
    });
  });

  describe("promise", function () {
    it("pass a promise which resolves immediatly", async function () {
      // Constructor
      let result = await each([new Promise((resolve) => resolve("ok"))]);
      result.should.eql(["ok"]);
      // Push
      result = await each().call([new Promise((resolve) => resolve("ok"))]);
      result.should.eql(["ok"]);
    });

    it("pass a promise which resolves in next tick", async function () {
      // Constructor
      let result = await each([
        new Promise((resolve) => setImmediate(() => resolve(1))),
        new Promise((resolve) => resolve(2)),
      ]);
      result.should.eql([1, 2]);
      // Push
      result = await each().call([
        new Promise((resolve) => setImmediate(() => resolve(1))),
        new Promise((resolve) => resolve(2)),
      ]);
      result.should.eql([1, 2]);
    });
  });
});
