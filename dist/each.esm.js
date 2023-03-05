const is_object_literal = function(obj) {
  let test = obj;
  if (typeof obj !== 'object' || obj === null) {
    return false;
  } else {
    if (Object.getPrototypeOf(test) === null) {
      return true;
    }
    while (Object.getPrototypeOf(test = Object.getPrototypeOf(test)) !== null) {
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
  for (const i in args) {
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
        concurrency: arg === true ? -1 : 1
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

function index() {
  const {items, options} = normalize.apply(null, arguments);
  const state = {
    defers: [],
    error: false,
    paused: options.pause,
    closed: false,
    running: 0,
    count: -1,
    stack: [],
  };
  const internal = {
    pump: function() {
      setImmediate(async function() {
        if (!state.stack.length) {
          return;
        }
        if (state.error && !options.relax) {
          while (state.stack.length) {
            const item = state.stack.shift();
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
        const item = state.stack.shift();
        if (item.type === 'END') {
          if(state.stack.length !== 0) console.error('INVALID_STATE');
          item.resolve();
          return;
        }
        state.running++;
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
      if(state.paused){
        state.defers.push({
          resolve: resolve,
          reject: reject,
          items: items
        });
        return;
      }
      if (Array.isArray(items)) {
        return Promise.all(
          items.map(item =>
            all(item, options)
          )
        ).then(resolve, reject);
      } else {
        state.stack.push({
          type: 'ITEM',
          handler: items,
          resolve: resolve,
          reject: reject,
          options: options
        });
        return internal.pump();
      }
    });
  };
  const wrap = (promise) => {
    promise.options = function() {
      if (arguments.length === 0) {
        return {...options};
      }else if (arguments.length === 1) {
        return options[arguments[0]];
      }else if (arguments.length === 2) {
        options[arguments[0]] = arguments[1];
        return promise;
      } else {
        throw Error(`EACH_OPTIONS_ARGUMENT_LENGTH: \`options\` expect one or two arguments, got ${arguments.length}`);
      }
    };
    promise.state = function() {
      return state;
    };
    promise.pause = function() {
      state.paused = true;
      return promise;
    };
    promise.call = function(items) {
      if (state.closed) {
        throw Error('EACH_CLOSED: cannot schedule new items when closed.');
      }
      return wrap(all(items));
    };
    promise.end = async function(options = {}) {
      if(!is_object_literal(options) && typeof options === 'object'){
        options = { error: options };
      }
      state.paused = false;
      state.closed = true;
      if (options.error){
        state.error = options.error;
      }
      // In force mode, unschedule all scheduled items
      if (options.force) {
        while (state.stack.length !== 0) {
          const item = state.stack.shift();
          item.resolve.call();
        }
        return;
      }
      // Free all defers items
      const defers = state.defers;
      state.defers = [];
      await Promise.all(
        defers.map((defer) => {
          if (state.error) {
            defer.reject(state.error);
          } else {
            defer.resolve(undefined);
          }
        })
      );
      if (state.error){
        return Promise.reject(state.error);
      }
      return new Promise(function(resolve, reject) {
        state.stack.push({
          type: 'END',
          resolve: resolve,
          reject: reject,
        });
        internal.pump();
      });
    };
    promise.resume = async function() {
      state.paused = false;
      const defers = state.defers;
      state.defers = [];
      internal.pump(); // Revive scheduled items if any
      const prom = Promise.all(
        defers.map((defer) =>
          all(defer.items)
            .then((data) => {
              defer.resolve(data);
              return Promise.resolve(data);
            }, (err) => {
              defer.reject(err);
              return Promise.reject(err);
            })
        )
      );
      return prom;
    };
    return promise;
  };
  return wrap(all(items));
}

export { index as default };
