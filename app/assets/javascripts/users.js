!function(app, $) {
  $(document).ready(function() {
    var users = window.autocompleteUsers;
    var searchQuery = $('.search-query');
    searchQuery.omniselect({
      source: function(request, response) {
        return $.ajax({
          url: $('.search-query').data('autocompleteurl'),
          dataType: "json",
          data: {
            name: request
          },
          success: function(data) {
            return response(data);
          }
        });
      },
      resultsClass: 'typeahead dropdown-menu',
      activeClass: 'active',
      itemLabel: function(user) {
        return user.name;
      },
      itemId: function(user) {
        return user.id;
      },
      renderItem: function(label) {
        return '<li><a href="#">' + label + '</a></li>';
      },
      filter: function(item, query) {
        return item.name.match(new RegExp(query, 'i'));
      }
    }).on('omniselect:select', function(event, id) {
      $(event.target).val();
      window.location = '/students/' + id;
      return false;
    });
  });
}(Gradecraft, jQuery);