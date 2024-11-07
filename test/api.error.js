import each from "../lib/index.js";

describe("api.error", function () {
  it("items scheduled after are rejected", function () {
    const scheduler = each();
    scheduler.error(Error("catchme"));
    return scheduler.call([1, 2]).should.be.rejectedWith("catchme");
  });

  it("items scheduled before are executed", async function () {
    const stack = [];
    const scheduler = each([1]);
    scheduler.then((value) => stack.push(value));
    scheduler.call(2).then((value) => stack.push(value));
    await scheduler.error(Error("catchme"));
    stack.should.eql([[1], 2]);
  });
});
