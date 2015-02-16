
var each = require('..');

each( [{id: 1}, {id: 2}, {id: 3}] )
.on('item', function(element, index, next) {
  console.log('element: ', element, '@', index);
  setTimeout(next, 500);
})
.on('error', function(err) {
  console.log(err.message);
})
.on('end', function() {
  console.log('Done');
});
