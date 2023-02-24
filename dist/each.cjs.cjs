'use strict';

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
  const stack = [];
  const state = {
    defers: [],
    error: false,
    paused: options.pause,
    closed: false,
    running: 0,
    count: -1
  };
  const internal = {
    pump: function() {
      setImmediate(async function() {
        if (!stack.length) {
          return;
        }
        if (state.error && !options.relax) {
          while (stack.length) {
            const item = stack.shift();
            item.reject.call(null, state.error);
          }
          return;
        }
        if (state.closed) {
          while (stack.length !== 0) {
            const item = stack.shift();
            item.resolve.call();
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
  scheduler.options = function() {
    if (arguments.length === 0) {
      return {...options};
    }else if (arguments.length === 1) {
      return options[arguments[0]];
    }else if (arguments.length === 2) {
      options[arguments[0]] = arguments[1];
      return scheduler;
    } else {
      throw Error(`EACH_OPTIONS_ARGUMENT_LENGTH: \`options\` expect one or two arguments, got ${arguments.length}`);
    }
  };
  scheduler.pause = function() {
    state.paused = true;
    return scheduler;
  };
  scheduler.call = function(items) {
    if (state.closed) {
      throw Error('EACH_CLOSED: cannot schedule new items when closed.');
    }
    return all(items);
  };
  scheduler.end = function(error) {
    const result = scheduler.resume();
    state.closed = true;
    if (error){
      state.error = error;
    }
    return result;
  };
  scheduler.resume = function() {
    state.paused = false;
    const defers = state.defers;
    state.defers = [];
    internal.pump(); // Revive scheduled items if any
    return Promise.all(
      defers.map((defer) =>
        all(defer.items).then(defer.resolve, defer.reject)
      )
    );
  };
  return scheduler;
}

module.exports = index;
