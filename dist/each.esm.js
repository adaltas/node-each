const is_object_literal = function(obj) {
  let test = obj;
  if (typeof obj !== 'object' || obj === null) {
    return false;
  } else {
    if (Object.getPrototypeOf(test) === null) {
      return true;
    }
    while (!false) {
      if (Object.getPrototypeOf(test = Object.getPrototypeOf(test)) === null) {
        break;
      }
    }
    return Object.getPrototypeOf(obj) === test;
  }
};

const normalize = function(...args) {
  let items = [];
  let options = {
    concurrency: 1,
    flatten: false,
    pause: false,
    relax: false
  };
  for (let i in args) {
    const arg = args[i];
    if (Array.isArray(arg)) {
      items = [...items, ...arg];
    } else if (is_object_literal(arg)) {
      options = {...options, ...arg};
    } else if (typeof arg === 'function') {
      options = {
        ...options,
        handler: arg
      };
    } else if (typeof arg === 'boolean') {
      options = {
        ...options,
        concurrency: typeof arg ? -1 : 1
      };
    } else if (typeof arg === 'number') {
      options = {
        ...options,
        concurrency: arg
      };
    } else {
      throw Error(`Invalid argument: argument at position ${i} must be one of array, object, function, boolean or number, got ${JSON.stringify(arg)}`);
    }
  }
  if(options.flatten === true){
    options.flatten = Infinity;
  } else if (options.flatten === false) {
    options.flatten = 0;
  }
  items = items.flat(options.flatten);
  return {
    items: items,
    options: options
  };
};

function index(...args) {
  const {items, options} = normalize.apply(null, arguments);
  const stack = [];
  const state = {
    error: false,
    paused: options.pause,
    running: 0,
    count: -1
  };
  const internal = {
    pump: function() {
      if (!stack.length) {
        return;
      }
      if (state.error && !options.relax) {
        let item;
        while (item = stack.shift()) {
          item.reject.call(null, state.error);
        }
        return;
      }
      if (state.paused) {
        return;
      }
      if (options.concurrency > 0 && state.running === options.concurrency) {
        return;
      }
      state.running++;
      const item = stack.shift();
      return setImmediate(async function() {
        try {
          state.count++;
          const result = options.handler
            ? await options.handler.call(null, item.handler, state.count)
            : typeof item.handler === 'function'
              ? await item.handler.call()
              : await item.handler;
          state.running--;
          item.resolve.call(null, result);
          return internal.pump();
        } catch (error) {
          state.running--;
          state.error = error;
          item.reject.call(null, error);
          return internal.pump();
        }
      });
    }
  };
  const all = function(items, options) {
    return new Promise(function(resolve, reject) {
      const isArray = Array.isArray(items);
      if (isArray) {
        return Promise.all((function() {
          let j, len;
          const results = [];
          for (j = 0, len = items.length; j < len; j++) {
            const item = items[j];
            results.push(all(item, options));
          }
          return results;
        })()).then(resolve, reject);
      } else {
        stack.push({
          handler: items,
          resolve: resolve,
          reject: reject,
          options: options
        });
        return internal.pump();
      }
    });
  };
  const scheduler = all(items);
  scheduler.get = function() {
    if (arguments.length === 0) {
      return {...options};
    }
    if (arguments.length === 1) {
      return options[arguments[0]];
    } else {
      throw Error(`Invalid argument: \`get\` expect one or two arguments, got ${arguments.length}`);
    }
  };
  scheduler.pause = function() {
    state.paused = true;
    return scheduler;
  };
  scheduler.call = function(items) {
    return all(items);
  };
  scheduler.resume = function() {
    state.paused = false;
    internal.pump();
    return scheduler;
  };
  return scheduler;
}

export { index as default };
