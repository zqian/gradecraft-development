// Leaderboard Page
$('table.dynatable').dynatable({

  readers: {
      rank: function(el, record) {
        return Number(el.innerHTML) || 0;
      }
      ,
      score: function(el, record) {
        return Number(el.innerHTML.replace(",","")) || 0;
      }
    }
});

$('table.nopage_dynatable').dynatable({

  features: {
        paginate: false,
      },
  readers: {
    rank: function(el, record) {
      return Number(el.innerHTML) || 0;
    },
    score: function(el, record) {
      return Number(el.innerHTML.replace(",","")) || 0;
    },
    totalScore: function(el, record) {
      return Number(el.innerHTML.replace(",","")) || 0;
    },
    badgeScore: function(el, record) {
      return Number(el.innerHTML.replace(",","")) || 0;
    }
  }
});

$('table.nosearch_dynatable').dynatable({

  features: {
        search: false
      },
  readers: {
      rank: function(el, record) {
        return Number(el.innerHTML) || 0;
      }
      ,
      score: function(el, record) {
        return Number(el.innerHTML.replace(",","")) || 0;
      }
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
      due: function(el, record) {
        record.parsedDate = Date.parse(el.innerHTML);
        return el.innerHTML;
      }
      ,
      points: function(el, record) {
        return Number(el.innerHTML.replace(",","")) || 0;
      }
      ,
      maxValue: function(el, record) {
        return Number(el.innerHTML.replace(",","")) || 0;
      }
    }
});
