import each from "../lib/index.js";

describe("api.end", function () {
  it("wait for running items before resolution", async function () {
    const stack = [];
    const handler = (id) => {
      stack.push(`${id}:start`);
      return new Promise((resolve) => {
        setTimeout(() => {
          stack.push(`${id}:end`);
          resolve();
        }, 20);
      });
    };
    const n = each(-1);
    n.call(() => handler(1));
    n.call(() => handler(2));
    n.call(() => handler(3));
    n.concurrency(1);
    n.call(() => handler(4));
    n.call(() => handler(5));
    n.call(() => handler(6));
    n.concurrency(-1);
    n.call(() => handler(7));
    n.call(() => handler(8));
    n.call(() => handler(9));
    await n.end();
    stack.should.eql([
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
      "7:start",
      "8:start",
      "9:start",
      "7:end",
      "8:end",
      "9:end",
    ]);
  });

  it("scheduled items are handled and root is resolved", async function () {
    const scheduler = each(
      [
        new Promise((resolve) => setTimeout(() => resolve(1), 10)),
        new Promise((resolve) => setTimeout(() => resolve(2), 100)),
        new Promise((resolve) => setTimeout(() => resolve(3), 100)),
      ],
      true,
    );
    setTimeout(() => {
      scheduler.end();
    }, 20);
    const result = await scheduler;
    result.should.eql([1, 2, 3]);
  });

  it("cannot call push when closed", async function () {
    const scheduler = each();
    await scheduler.call(() => 1);
    scheduler.end();
    scheduler
      .call(() => 2)
      .should.be.rejectedWith(
        "EACH_CLOSED: cannot schedule new items when closed.",
      );
  });

  it("error in an item propaged to close", async function () {
    const scheduler = each();
    scheduler.call(
      () =>
        new Promise((resolve, reject) =>
          setTimeout(() => {
            reject(new Error("catchme"));
          }, 10),
        ),
    );
    scheduler.end().should.be.rejectedWith("catchme");
  });

  describe("options.force", function () {
    it("by default, after Initialisation", async function () {
      const scheduler = each(["a", "b", "c"]);
      scheduler.end();
      const result = await scheduler;
      result.should.eql(["a", "b", "c"]);
    });

    it("when active, after Initialisation", async function () {
      const scheduler = each(["a", "b", "c"]);
      scheduler.end({ force: true });
      const result = await scheduler;
      result.should.eql([undefined, undefined, undefined]);
    });

    it("by default, scheduled items are handled", async function () {
      const scheduler = each([
        new Promise((resolve) => setTimeout(() => resolve(1), 10)),
        new Promise((resolve) => setTimeout(() => resolve(2), 100)),
        new Promise((resolve) => setTimeout(() => resolve(3), 100)),
      ]);
      setTimeout(() => {
        scheduler.end();
      }, 20);
      const result = await scheduler;
      result.should.eql([1, 2, 3]);
    });

    it("when active, unscheduled items are not handled", async function () {
      const scheduler = each([
        new Promise((resolve) => setTimeout(() => resolve(1), 10)),
        new Promise((resolve) => setTimeout(() => resolve(2), 100)),
        new Promise((resolve) => setTimeout(() => resolve(3), 100)),
      ]);
      setTimeout(() => {
        scheduler.end({ force: true });
      }, 20);
      const result = await scheduler;
      result.should.eql([1, 2, undefined]);
    });
  });

  describe("options.error", function () {
    it("when new items are to be scheduled", async function () {
      const scheduler = each([
        new Promise((resolve) => setTimeout(() => resolve(1), 10)),
        new Promise((resolve) => setTimeout(() => resolve(2), 100)),
        new Promise((resolve) => setTimeout(() => resolve(3), 100)),
      ]);
      setTimeout(() => {
        scheduler.end(new Error("closing"));
      }, 20);
      scheduler.should.be.rejectedWith("closing");
    });

    it("when no new items are to be scheduled", async function () {
      const scheduler = each([
        new Promise((resolve) => setTimeout(() => resolve(1), 10)),
        new Promise((resolve) => setTimeout(() => resolve(2), 100)),
        new Promise((resolve) => setTimeout(() => resolve(3), 100)),
      ]);
      setTimeout(() => {
        scheduler.end(new Error("closing"));
      }, 200);
      scheduler.should.be.resolvedWith([1, 2, 3]);
    });

    it("cannot call push when closed with an error", async function () {
      const scheduler = each();
      await scheduler.call(() => 1);
      scheduler.end(new Error("closing"));
      scheduler
        .call(() => 2)
        .should.be.rejectedWith(
          "EACH_CLOSED: cannot schedule new items when closed.",
        );
    });

    it("has no effect if each.relax is active", async function () {
      const scheduler = each(
        [
          new Promise((resolve) => setTimeout(() => resolve(1), 10)),
          new Promise((resolve) => setTimeout(() => resolve(2), 100)),
          new Promise((resolve) => setTimeout(() => resolve(3), 100)),
        ],
        { relax: true },
      );
      setTimeout(() => {
        scheduler.end(new Error("closing"));
      }, 20);
      scheduler.should.be.resolvedWith([1, 2, 3]);
    });
  });

  describe("state.pause", function () {
    it("end resolve as undefined if not error", async function () {
      const stack = [];
      const eacher = each({ pause: true });
      eacher.call([1, 2]).then((value) => stack.push(value));
      eacher.then((value) => stack.push(value));
      return new Promise((resolve, reject) => {
        setTimeout(async () => {
          try {
            await eacher.end();
            stack.should.eql([undefined, undefined]);
            resolve();
          } catch (err) {
            reject(err);
          }
        }, 20);
      });
    });

    it("end reject error when provided", async function () {
      const stack = { resolve: [], reject: [] };
      const eacher = each({ pause: true });
      eacher
        .call([1, 2])
        .then((value) => stack.resolve.push(value))
        .catch((err) => stack.reject.push(err.message));
      eacher
        .then((value) => stack.resolve.push(value))
        .catch((err) => stack.reject.push(err.message));
      return new Promise((resolve, reject) => {
        setTimeout(async () => {
          try {
            await eacher.end(new Error("catchme"));
            reject(new Error("ohno"));
          } catch (err) {
            err.message.should.eql("catchme");
            stack.resolve.should.eql([]);
            stack.reject.should.match(["catchme", "catchme"]);
            resolve();
          }
        }, 20);
      });
    });
  });
});
