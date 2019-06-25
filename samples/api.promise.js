
var each = require('..');

each( [{id: 1}, {id: 2}, {id: 3}] )
.call( function(element, index, next){
  console.log('element: ', element, '@', index);
  setTimeout(next, 500);
})
.next( function(err){
  console.log(err ? err.message : 'Done');
});

// Print:
// element:  { id: 1 } @ 0
// element:  { id: 2 } @ 1
// element:  { id: 3 } @ 2
// Done
