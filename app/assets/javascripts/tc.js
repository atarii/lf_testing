(function () {
  /**
   * Assign objects in hash to namespace
   * @usage tc.using("tc.[namespace]", [self-exectuting function that returns a hash of objects to attach]);
   * @example tc.using("tc.page", function () { return { name: "dashboard"}; }());
   */
  var using = function (namespace, objects) {
    // create namespace object chain
    var parts = namespace.split(".");
    var parent = window;
    for (var i = 0; i < parts.length; i++) {
      var part = parts[i];
      if (parent[part] === undefined) parent[part] = {};
      parent = parent[part];
    }

    // attach named objects to namespace object
    var keys = Object.keys(objects);
    for (var x = 0; x < keys.length; x++) {
      var key = keys[x];
      parent[key] = objects[key];
    }
  };

  // attach "using" local function to "tc" namespace
  using('tc', { using: using });
}());
