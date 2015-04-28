$('.passed-failed-grade-toggle label').click(function(){
    if ($( ".passed-failed-grade-toggle input:checked" ).length > 0) {
      $('.pass-fail-contingent').text("Failed");
    } else {
      $('.pass-fail-contingent').text("Passed");;
    };
  });
