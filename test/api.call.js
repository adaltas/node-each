import each from "../lib/index.js";

describe("api.call", function () {
  describe("parallel sync", function () {
    it("function", function () {
      const scheduler = each();
      return Promise.all([
        scheduler.call(() => new Promise((resolve) => resolve(1))),
        scheduler.call(() => new Promise((resolve) => resolve(2))),
      ]).should.be.resolvedWith([1, 2]);
    });

    it("an array", function () {
      const scheduler = each();
      return Promise.all([
        scheduler.call([
          () => new Promise((resolve) => resolve(1)),
          () => new Promise((resolve) => resolve(2)),
        ]),
        scheduler.call([
          () => new Promise((resolve) => resolve(3)),
          () => new Promise((resolve) => resolve(4)),
        ]),
      ]).should.be.resolvedWith([
        [1, 2],
        [3, 4],
      ]);
    });

    it("an empty array", function () {
      const scheduler = each();
      return Promise.all([
        scheduler.call([]),
        scheduler.call([]),
      ]).should.be.resolvedWith([[], []]);
    });
  });

  describe("parallel async", function () {
    it("function", function () {
      const scheduler = each();
      return Promise.all([
        scheduler.call(
          () => new Promise((resolve) => setTimeout(() => resolve(1), 50)),
        ),
        scheduler.call(
          () => new Promise((resolve) => setTimeout(() => resolve(2), 100)),
        ),
        scheduler.call(
          () => new Promise((resolve) => setTimeout(() => resolve(3), 50)),
        ),
      ]).should.be.resolvedWith([1, 2, 3]);
    });

    it("an array", function () {
      const scheduler = each();
      return Promise.all([
        scheduler.call([
          () => new Promise((resolve) => setTimeout(() => resolve(1), 50)),
          () => new Promise((resolve) => setTimeout(() => resolve(2), 100)),
          () => new Promise((resolve) => setTimeout(() => resolve(3), 50)),
        ]),
        scheduler.call([
          () => new Promise((resolve) => setTimeout(() => resolve(4), 50)),
          () => new Promise((resolve) => setTimeout(() => resolve(5), 100)),
          () => new Promise((resolve) => setTimeout(() => resolve(6), 50)),
        ]),
      ]).should.be.resolvedWith([
        [1, 2, 3],
        [4, 5, 6],
      ]);
    });
  });

  describe("fluent", function () {
    it("return the last value", function () {
      return each()
        .call(() => 1)
        .call(() => 2)
        .call(() => 3)
        .should.be.resolvedWith(3);
    });

    it("return the last promise", function () {
      return each()
        .call(() => new Promise((resolve) => setImmediate(() => resolve(1))))
        .call(() => new Promise((resolve) => setImmediate(() => resolve(2))))
        .call(() => new Promise((resolve) => setImmediate(() => resolve(3))))
        .should.be.resolvedWith(3);
    });

    it("return the first rejected error in strict mode", function () {
      return each()
        .call(() => new Promise((resolve) => setImmediate(() => resolve(1))))
        .call(
          () => new Promise((resolve, reject) => setImmediate(() => reject(2))),
        )
        .call(
          () => new Promise((resolve, reject) => setImmediate(() => reject(3))),
        )
        .should.be.rejectedWith(2);
    });

    it("return the first thrown error in strict mode", function () {
      return each()
        .call(
          () =>
            new Promise(() => {
              throw Error(1);
            }),
        )
        .call(
          () =>
            new Promise(() => {
              throw Error(2);
            }),
        )
        .call(
          () =>
            new Promise(() => {
              throw Error(3);
            }),
        )
        .should.be.rejectedWith(2);
    });

    it("return the last rejected error in relax mode", function () {
      return each({ relax: true })
        .call(() => new Promise((resolve) => setImmediate(() => resolve(1))))
        .call(
          () => new Promise((resolve, reject) => setImmediate(() => reject(2))),
        )
        .call(
          () => new Promise((resolve, reject) => setImmediate(() => reject(3))),
        )
        .should.be.rejectedWith(3);
    });

    it("return the last thrown error in relax mode", function () {
      return each({ relax: true })
        .call(
          () =>
            new Promise(() => {
              throw Error(1);
            }),
        )
        .call(
          () =>
            new Promise(() => {
              throw Error(2);
            }),
        )
        .call(
          () =>
            new Promise(() => {
              throw Error(3);
            }),
        )
        .should.be.rejectedWith(3);
    });
  });

  describe("error", function () {
    it("throw error", function () {
      const scheduler = each();
      return scheduler
        .call(() => "ok")
        .call(() => {
          throw Error("catchme");
        })
        .call(() => "ok")
        .should.be.rejectedWith("catchme");
    });

    it("reject error in same tick", function () {
      const scheduler = each();
      return scheduler
        .call(() => "ok")
        .call(() => new Promise((resolve, reject) => reject(Error("catchme"))))
        .call(() => "ok")
        .should.be.rejectedWith("catchme");
    });

    it("reject error in next tick", function () {
      const scheduler = each();
      return scheduler
        .call(() => "ok")
        .call(
          () =>
            new Promise((resolve, reject) =>
              setImmediate(() => reject(Error("catchme"))),
            ),
        )
        .call(() => "ok")
        .should.be.rejectedWith("catchme");
    });
  });
});
