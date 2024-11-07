import each from "../lib/index.js";

describe("api.resume", function () {
  it("return a promise", function () {
    each().resume().should.be.a.Promise();
  });

  it("may be call over an unpaused status", async function () {
    const eacher = each({ pause: true });
    eacher.resume();
    eacher.resume();
    await eacher.end();
  });

  describe("resolution", function () {
    it("items resolve to an items", async function () {
      const scheduler = each([1, 2, 3], { pause: true });
      const promRoot = scheduler;
      const promCall = scheduler.call([4, 5, 6]);
      scheduler.resume();
      const result = await Promise.all([promRoot, promCall]);
      result.should.eql([
        [1, 2, 3],
        [4, 5, 6],
      ]);
    });

    it("scalar item resolve to scalar item", async function () {
      // each only accept arrays at initialization
      // but call accept single items
      const scheduler = each(["a"], { pause: true });
      const promRoot = scheduler;
      const promCall = scheduler.call("b");
      scheduler.resume();
      const result = await Promise.all([promRoot, promCall]);
      result.should.eql([["a"], "b"]);
    });
  });

  describe("throttling", function () {
    it("resolve before resume", async function () {
      const eacher = each(
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
        (item) => {
          if (item.id === 2) {
            eacher.pause();
            setTimeout(() => {
              eacher.resume();
            }, 100);
          }
        },
      );
      await eacher;
    });

    it("resolve after resume", async function () {
      const eacher = each(
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
        (item) => {
          if (item.id === 2) {
            eacher.pause();
            return new Promise((resolve) => {
              setTimeout(() => {
                eacher.resume();
                resolve();
              }, 100);
            });
          }
        },
      );
      await eacher;
    });

    it("resolve after resume with multiple pause/resume", async function () {
      const eacher = each(
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
        (item) => {
          if (item.id % 2 === 0) {
            eacher.pause();
            return new Promise((resolve) => {
              setTimeout(() => {
                eacher.resume();
                resolve();
              }, 10 * item.id);
            });
          }
        },
      );
      await eacher;
    });

    it("resolve before resume with multiple pause", async function () {
      const eacher = each(
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
        (item) => {
          if (item.id % 2 === 0) {
            eacher.pause();
            setTimeout(() => {
              eacher.resume();
            }, 10 * item.id);
          }
        },
      );
      await eacher;
    });
  });

  describe("error", function () {
    it("pass error while in pause", function () {
      const eacher = each({ pause: true });
      eacher.call(
        () => new Promise((resolve) => setImmediate(() => resolve("before"))),
      );
      eacher.call(
        () =>
          new Promise((resolve, reject) =>
            setImmediate(() => reject(new Error("catchme"))),
          ),
      );
      eacher.call(
        () => new Promise((resolve) => setImmediate(() => resolve("after"))),
      );
      return eacher.resume().should.be.rejectedWith("catchme");
    });
  });
});
