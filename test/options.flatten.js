import each from "../lib/index.js";

describe("options.flatten", function () {
  it("value `true` in constructor", function () {
    return each(["a", ["b", "c"], ["d", ["e", ["f", ["g"]]]]], {
      flatten: true,
    }).should.be.resolvedWith(["a", "b", "c", "d", "e", "f", "g"]);
  });

  it("value `false` in constructor", function () {
    return each(["a", ["b", "c"], ["d", ["e", ["f", ["g"]]]]], {
      flatten: false,
    }).should.be.resolvedWith(["a", ["b", "c"], ["d", ["e", ["f", ["g"]]]]]);
  });

  it("value `1` in constructor", function () {
    return each(["a", ["b", "c"], ["d", ["e", ["f", ["g"]]]]], {
      flatten: 1,
    }).should.be.resolvedWith(["a", "b", "c", "d", ["e", ["f", ["g"]]]]);
  });
});
