import each from "../lib/index.js";

describe("api.options", function () {
  it("validation", async function () {
    await each()
      .options(1, 2, 3)
      .should.be.rejectedWith(
        "EACH_OPTIONS_ARGUMENT_LENGTH: `options` expect one or two arguments, got 3.",
      );
  });

  it("0 arg, return all options", function () {
    each().options().should.match({
      concurrency: 1,
      flatten: 0,
      pause: false,
      relax: false,
    });
  });

  it("1 arg, get an options", function () {
    each().options("concurrency").should.resolvedWith(1);
  });

  it("2 args, set an options", function () {
    each()
      .options("concurrency", 2)
      .options("concurrency")
      .should.resolvedWith(2);
  });

  it("options(concurrency) map to api.concurrency with get", async function () {
    await each()
      .options("concurrency", 42)
      .concurrency()
      .should.be.resolvedWith(42);
  });

  it("options(concurrency) map to api.concurrency with set", async function () {
    await each()
      .concurrency(42)
      .options("concurrency")
      .should.be.resolvedWith(42);
  });
});
