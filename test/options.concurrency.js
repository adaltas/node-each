import each from "../lib/index.js";

describe("options.flatten", function () {
  it("value invalid", function () {
    // Note, errors in option normalization shall probably be handled with a rejected promise.
    (() => {
      each([], { concurrency: "invalid" });
    }).should.throw(
      "Invalid argument: option concurrency must be a boolean or a number.",
    );
  });

  it("value `true` is converted to -1", function () {
    const scheduler = each([], { concurrency: true });
    scheduler.options("concurrency").should.resolvedWith(-1);
  });

  it("value `false` is converted to 1", function () {
    const scheduler = each([], { concurrency: false });
    scheduler.options("concurrency").should.resolvedWith(1);
  });
});
