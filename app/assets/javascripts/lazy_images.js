var ready = function() {
  $('.lazy').visibility({
    type       : 'image',
    transition : 'fade in',
    duration   : 300
  });
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);
