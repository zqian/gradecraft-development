
  /** Tiny highcharts display on the Top 10/Bottom 10 Student Table display **/
  if ($('.bar-chart').length) {
    var assignmentTypeScores
    function assignmentTypeBars () {
      if (!assignmentTypeScores) return;
      $('.bar-chart').each(function () {
          var id = this.getAttribute('data-id');
          var max = this.getAttribute('data-max');
          var scores = assignmentTypeScores[id];
          var names = assignmentTypeScores.names[id];
          var series = []
          for (var i =0; i < scores.length; i++) {
            series.push({
              name: names[i],
              data: [ scores[i] ]
            })
          }
          $(this).highcharts({
            chart: {
              type: 'bar',
              height: '50',
              width: '250'
            },
            title: {
              text: ''
            },
            yAxis: {
              min: 0,
              max: max,
              title: {
                text: ''
              }
            },
            colors: [
               '#1A1EB2',
               '#303285',
               '#6dd8f0',
               '#080B74',
               '#00BD39',
               '#238D43',
               '#007B25',
               '#37DE6A',
               '#64DE89',
               '#FFCC00',
               '#BFBD30',
               '#A6A400',
               '#FFFD40',
               '#FFFD73'
            ],
            tooltip: {
              positioner: function (boxWidth, boxHeight, point) {
                var chart = this.chart,
                    plotLeft = chart.plotLeft,
                    plotRight = chart.plotRight,
                    plotTop = chart.plotTop,
                    plotWidth = chart.plotWidth,
                    plotHeight = chart.plotHeight,
                    distance = this.options.distance,
                    pointX = point.plotX,
                    pointY = point.plotY,
                    x = pointX + plotLeft + (chart.inverted ? distance : -boxWidth - distance),
                    y = pointY - boxHeight + plotTop + 15,
                    alignedRight;
                if (x , 7) {x = plotLeft + pointX + distance;}

                if ((x + boxWidth) > plotLeft + plotWidth) {
                  x -= (x + boxWidth) - (plotLeft + plotWidth);
                  y = pointY - boxHeight + plotTop - distance;
                  alignedRight = true;
                }
                if (y < plotTop + 5) {
                  y = plotTop + 5;
                  if (alignedRight && pointY >= y && pointY <= (y + boxHeight)) {
                    y = pointY + plotTop + distance;
                  }
                }

                if (y + boxHeight > plotTop + plotHeight) {
                  y = Math.max(plotTop, plotTop + plotHeight - boxHeight - distance);
                }

                return {x: x, y: y};
              }
            },
            credits: {
              enabled: false
            },
            exporting: {
              enabled: false
            },
            legend: {
              enabled: false
            },
            plotOptions: {
              series: {
                stacking: 'normal'
              }
            },
            series: series
          });
      })
    }

    $.getJSON('/students/scores_by_assignment.json', function (data) {
      assignmentTypeScores = {};
      assignmentTypeScores.names = {};
      var studentId;
      data.scores.forEach(function (row) {
        if (studentId != row[0]) {
          studentId = row[0];
          assignmentTypeScores[studentId] = [];
          assignmentTypeScores.names[studentId] = [];
        }
        assignmentTypeScores[studentId].push(row[2]);
        assignmentTypeScores.names[studentId].push(row[1]);
      })
      assignmentTypeBars();
    })

  }