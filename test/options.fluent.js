import each from "../lib/index.js";
import should from "should";

describe("options.fluent", function () {
  it("call is chainable by default", function () {
    const scheduler = each().call(1);
    should.exist(scheduler.options);
  });

  it("call is chainable if `true`", function () {
    const scheduler = each({ fluent: true }).call(1);
    should.exist(scheduler.options);
  });

  it("call is not chainable if `false`", function () {
    const scheduler = each({ fluent: false }).call(1);
    should.not.exist(scheduler.options);
  });
});
