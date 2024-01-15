(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
  typeof define === 'function' && define.amd ? define(factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, global.mixme = factory());
})(this, (function () { 'use strict';

  const is_object_literal = function (obj) {
    let test = obj;
    if (typeof obj !== "object" || obj === null) {
      return false;
    } else {
      if (Object.getPrototypeOf(test) === null) {
        return true;
      }
      while (
        Object.getPrototypeOf((test = Object.getPrototypeOf(test))) !== null
      ) {
      }
      return Object.getPrototypeOf(obj) === test;
    }
  };

  const normalize = function (args) {
    let items = [];
    let options = {
      concurrency: 1,
      flatten: false,
      pause: false,
      relax: false,
    };
    for (const i in args) {
      const arg = args[i];
      if (Array.isArray(arg)) {
        items = [...items, ...arg];
      } else if (is_object_literal(arg)) {
        options = { ...options, ...arg };
      } else if (typeof arg === "function") {
        options = {
          ...options,
          handler: arg,
        };
      } else if (typeof arg === "boolean") {
        options = {
          ...options,
          concurrency: arg,
        };
      } else if (typeof arg === "number") {
        options = {
          ...options,
          concurrency: arg,
        };
      } else {
        throw Error(
          `Invalid argument: argument at position ${i} must be one of array, object, function, boolean or number, got ${JSON.stringify(
          arg
        )}`
        );
      }
    }
    if (options.concurrency === true) {
      options.concurrency = -1;
    } else if (options.concurrency === false) {
      options.concurrency = 1;
    } else if (typeof options.concurrency !== 'number') {
      throw Error(`Invalid argument: option concurrency must be a boolean or a number.`);
    }
    if (options.flatten === true) {
      options.flatten = Infinity;
    } else if (options.flatten === false) {
      options.flatten = 0;
    }
    if (
      options.fluent === null ||
      options.fluent === undefined ||
      options.fluent === true
    ) {
      options.fluent = true;
    } else if (options.fluent !== false) {
      throw Error(`Invalid argument: option fluent must be true or false.`);
    }
    items = items.flat(options.flatten);
    return {
      items: items,
      options: options,
    };
  };

  const catcher = (promise) => {
    promise.catch(function () {});
    return promise;
  };

  const detach = setImmediate !== undefined ? setImmediate : setTimeout;

  function index (...args) {
    const { items, options } = normalize(args);
    const state = {
      defers: [],
      error: false,
      paused: options.pause,
      closed: false,
      concurrency: options.concurrency,
      running: 0,
      count: 0,
      stack: [],
      stack_running: [],
      close_item: undefined,
    };
    const internal = {
      pump: function () {
        detach(async function () {
          if (state.closed && state.close_item && state.stack_running.length === 0) {
            if (state.error && !options.relax) {
              state.close_item.reject(state.error);
            } else {
              state.close_item.resolve();
            }
            return;
          }
          if (!state.stack.length) {
            return;
          }
          if (state.paused) {
            return;
          }
          if (state.concurrency > 0 && state.running >= state.concurrency) {
            return;
          }
          const item = state.stack.shift();
          if (item.type === "END") {
            // Place the item on the side to ensure that running item are completed.
            state.close_item = item;
            internal.pump();
            return;
          } else if (item.type === "ERROR") {
            state.error = item.value;
            item.resolve();
            return;
          } else if (item.type === "CONCURRENCY") {
            if (item.value !== undefined) {
              state.concurrency = item.value;
              item.resolve(state.concurrency);
            } else {
              item.resolve(state.concurrency);
            }
            // Pump the necessary amount of item between the number of running
            // items and the targeted possible concurrency level.
            const repeat = state.concurrency === -1 ? state.stack.length : state.concurrency - state.running;
            for(let i = 0; i < repeat; i++){
              internal.pump();
            }
            return;
          }
          if (state.error && !options.relax) {
            item.reject.call(null, state.error);
            return;
          }
          state.stack_running.push(item);
          state.running++;
          try {
            state.count++;
            const result = options.handler
              ? await options.handler.call(null, item.handler, state.count - 1)
              : typeof item.handler === "function"
                ? await item.handler.call()
                : await item.handler;
            const position = state.stack_running.map(i => i === item ? i : -1).filter(i => i !== -1);
            state.stack_running.splice(position, 1);
            state.running--;
            item.resolve.call(null, result);
            internal.pump();
          } catch (error) {
            const position = state.stack_running.map(i => i === item ? i : -1).filter(i => i !== -1);
            state.stack_running.splice(position, 1);
            state.running--;
            state.error = error;
            item.reject.call(null, error);
            internal.pump();
          }
        });
      },
    };
    const all = function (items) {
      return catcher(
        new Promise(function (resolve, reject) {
          if (state.paused) {
            state.defers.push({
              resolve: resolve,
              reject: reject,
              items: items,
            });
            return;
          }
          if (Array.isArray(items)) {
            Promise.all(items.map((item) => all(item))).then(
              resolve,
              reject
            );
          } else {
            state.stack.push({
              type: "ITEM",
              handler: items,
              resolve: resolve,
              reject: reject,
              options: options,
            });
            internal.pump();
          }
        })
      );
    };
    const wrap = (promise, fluent) => {
      if (!fluent) {
        return promise;
      }
      promise.concurrency = function () {
        if (arguments.length === 0) {
          return wrap(
            new Promise(function (resolve, reject) {
              state.stack.push({
                type: "CONCURRENCY",
                value: undefined,
                resolve: resolve,
                reject: reject,
              });
              internal.pump();
            }),
            options.fluent
          );
        } else if (arguments.length === 1) {
          const [value] = arguments;
          return wrap(
            new Promise(function (resolve, reject) {
              state.stack.push({
                type: "CONCURRENCY",
                value: value,
                resolve: resolve,
                reject: reject,
              });
              internal.pump();
            }),
            options.fluent
          );
        } else {
          Promise.reject(
            Error(
              `EACH_CONCURRENCY_ARGUMENT_LENGTH: \`concurrency\` expect zero or one argument, got ${arguments.length}.`
            )
          );
        }
      };
      promise.options = function () {
        if (arguments.length === 0) {
          return { ...options };
        } else if (arguments.length === 1) {
          const [key] = arguments;
          if (key === "concurrency") {
            return promise.concurrency();
          } else {
            return Promise.resolve(options[arguments[0]]);
          }
        } else if (arguments.length === 2) {
          const [key, value] = arguments;
          if (key === "concurrency") {
            return promise.concurrency(value);
          } else {
            options[arguments[0]] = arguments[1];
            return promise;
          }
        } else {
          return Promise.reject(
            Error(
              `EACH_OPTIONS_ARGUMENT_LENGTH: \`options\` expect one or two arguments, got ${arguments.length}.`
            )
          );
        }
      };
      promise.state = function () {
        return state;
      };
      promise.pause = function () {
        state.paused = true;
        return promise;
      };
      promise.call = function (items) {
        if (state.closed) {
          return Promise.reject(Error("EACH_CLOSED: cannot schedule new items when closed."));
        }
        return wrap(all(items), options.fluent);
      };
      promise.end = function (opts = {}) {
        if (!is_object_literal(opts) && typeof opts === "object") {
          opts = { error: opts };
        }
        state.paused = false;
        state.closed = true;
        if (opts.error && !options.relax) {
          state.error = opts.error;
        }
        // In force mode, unschedule all scheduled items
        if (opts.force) {
          while (state.stack.length !== 0) {
            state.stack.shift().resolve();
          }
          return;
        }
        // Free all defers items
        while (state.defers.length !== 0) {
          const promise = state.defers.shift();
          if (state.error) {
            promise.reject(state.error);
          } else {
            promise.resolve();
          }
        }
        return catcher(
          new Promise(function (resolve, reject) {
            state.stack.push({
              type: "END",
              resolve: resolve,
              reject: reject,
            });
            internal.pump();
          })
        );
      };
      promise.error = function (error) {
        return catcher(
          new Promise(function (resolve, reject) {
            state.stack.push({
              type: "ERROR",
              resolve: resolve,
              reject: reject,
              value: error,
            });
            internal.pump();
          })
        );
      };
      promise.resume = function () {
        state.paused = false;
        const defers = state.defers;
        state.defers = [];
        internal.pump(); // Revive scheduled items if any
        const promise = catcher(
          Promise.all(
            defers.map((defer) =>
              all(defer.items).then(
                (data) => {
                  defer.resolve(data);
                  return Promise.resolve(data);
                },
                (err) => {
                  defer.reject(err);
                  return Promise.reject(err);
                }
              )
            )
          )
        );
        return promise;
      };
      return promise;
    };
    return wrap(all(items), true);
  }

  return index;

}));
