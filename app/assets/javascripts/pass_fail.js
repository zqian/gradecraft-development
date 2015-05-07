!function($) {

  // Toggle input field visibility on:
  // assignments/_form.haml

  $('.pass-fail-toggle label').click(function(){
    if ($( ".pass-fail-toggle input:checked" ).length > 0) {
      $('.pass-fail-contingent').css({ "visibility": "visible"});
    } else {
      $('.pass-fail-contingent').css({ "visibility": "hidden"});
    };
  });


  // Toggle label on:
  //   grades/_standard_edit.html.haml
  //   students/predictor/_assignments.haml

  $('.pass-fail-grade-toggle label').click(function(){
    var on = $('.pass-fail-contingent').data("on");
    var off = $('.pass-fail-contingent').data("off");
    if ($( ".pass-fail-grade-toggle input:checked" ).length > 0) {
      $('.pass-fail-contingent').text(off);
    } else {
      $('.pass-fail-contingent').text(on);;
    };
  });

}(jQuery);
