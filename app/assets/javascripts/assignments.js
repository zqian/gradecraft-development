!function($) {
  var $document = $(document), $link, selector;

  var init = function() {
    $document = $(document);
    $document.on('click', '.add-assignment-rubric a', addAssignmentRubric);
    $document.on('click', '.remove-assignment-rubric', removeAssignmentRubric);
  };

  var addAssignmentRubric = function(e) {
    $link = $(this), selector = $link.attr('href');
    $(selector).removeClass('hidden').find('input.destroy').val(false);
    $link.closest('li').addClass('disabled');
    e.preventDefault();
  };

  var removeAssignmentRubric = function() {
    $link = $(this), selector = $link.attr('href');
    $(selector).addClass('hidden');
    $link.prev('input.destroy').val(true);
    $('.add-assignment-rubric a[href="' + selector + '"]').closest('li').removeClass('disabled');
    return false;
  };

  if($('.assignment_options > input').is(':checked')) {
    $('ul > .submit').show();
  } else {
    $('ul > .submit').hide();
  }

  $('.assignment_options').change(function(){
    if($(this).is(":checked")) {
      $('ul > .submit').toggle();
    } else {
      $('ul > .submit').toggle();
    }
  });

  $('.pass-fail-toggle label').click(function(){
    if ($( ".pass-fail-toggle input:checked" ).length > 0) {
      $('.pass-fail-contingent').css({ "visibility": "visible"});
    } else {
      $('.pass-fail-contingent').css({ "visibility": "hidden"});
    };

    //$('.pass-fail-contingent').toggle();
  });

  $(init);
}(jQuery);
