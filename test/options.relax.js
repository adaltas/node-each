import each from "../lib/index.js";

describe("options.relax", function () {
  it("default `false` in constructor", function () {
    return each([
      () => new Promise((resolve) => resolve(1)),
      () => new Promise((resolve, reject) => reject(2)),
      () => new Promise((resolve) => resolve(3)),
    ]).should.be.rejectedWith(2);
  });

  it("default `false` and multiple call", function () {
    const scheduler = each();
    const prom1 = scheduler.call(
      () =>
        new Promise((resolve) => {
          resolve(1);
        }),
    );
    const prom2 = scheduler.call(
      () =>
        new Promise((resolve, reject) => {
          reject(2);
        }),
    );
    const prom3 = scheduler.call(
      () =>
        new Promise((resolve) => {
          resolve(3);
        }),
    );

    return Promise.allSettled([prom1, prom2, prom3]).then((values) => {
      values.should.eql([
        { status: "fulfilled", value: 1 },
        { status: "rejected", reason: 2 },
        { status: "rejected", reason: 2 },
      ]);
    });
  });

  it("when `true` with array in constructor has no effect", function () {
    return each(
      [
        () => new Promise((resolve) => resolve(1)),
        () => new Promise((resolve, reject) => reject(2)),
        () => new Promise((resolve) => resolve(3)),
      ],
      { relax: true },
    ).should.be.rejectedWith(2);
  });

  it("when `true` and multiple push", function () {
    const scheduler = each({ relax: true });
    const prom1 = scheduler.call(
      () =>
        new Promise((resolve) => {
          resolve(1);
        }),
    );
    const prom2 = scheduler.call(
      () =>
        new Promise((resolve, reject) => {
          reject(2);
        }),
    );
    const prom3 = scheduler.call(
      () =>
        new Promise((resolve) => {
          resolve(3);
        }),
    );

    return Promise.allSettled([prom1, prom2, prom3]).then((values) => {
      values.should.eql([
        { status: "fulfilled", value: 1 },
        { status: "rejected", reason: 2 },
        { status: "fulfilled", value: 3 },
      ]);
    });
  });
});
