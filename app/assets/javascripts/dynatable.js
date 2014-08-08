// Leaderboard Page
$('table.dynatable').dynatable({

  readers: {
      rank: function(el, record) {
        return Number(el.innerHTML) || 0;
      }
      // If you uncomment this section the values in the table for sort disappear
      // ,
      // score: function(el, record) {
      //   return Number(el.innerHTML) || 0;
      // }
    }
});

$('table.nopage_dynatable').dynatable({

  features: {
        paginate: false,
      }
});

$('table.nosearch_dynatable').dynatable({

  features: {
        search: false
      }
});

$('table.nopage_orsearch_dynatable').dynatable({

  features: {
        search: false,
        paginate: false
      }
});

$('table.nofeatures_dynatable').dynatable({

  features: {
        paginate: false,
        search: false,
        recordCount: false
      },
  readers: {
      'date': function(el, record) {
        record.parsedDate = Date.parse(el.innerHTML);
        return el.innerHTML;
      }
    }
});
