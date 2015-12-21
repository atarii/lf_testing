//= require Chart.js

function load_pie_chart() {
  window.onload = function () {
    var pass = $("div>span.passed + span").text().replace('+', '').trim();
    var fail = $("div>span.failed + span").text().replace('+', '').trim();
    var na = $("div>span.n_a + span").text().trim();

    var pieData = [
      {
        value: pass,
        color: "#5CB85C",
        label: "Pass"
      },
      {
        value: fail,
        color: "#F00000",
        label: "Fail"
      },
      {
        value: na,
        color: "#DAA520",
        label: "Uncertain"
      }
    ];

    var pieOptions = {
      //Boolean - Whether we should show a stroke on each segment
      segmentShowStroke: true,

      //String - The colour of each segment stroke
      segmentStrokeColor: "#FFFFFF",

      //Number - The width of each segment stroke
      segmentStrokeWidth: 2,

      //Number - Amount of animation steps
      animationSteps: 100,

      //String - Animation easing effect
      animationEasing: "easeOutBounce",

      //Boolean - Whether we animate the rotation of the Doughnut
      animateRotate: false,

      //Boolean - Whether we animate scaling the Doughnut from the centre
      animateScale: false,

      legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>",

      bezierCurve : false,
      animation: false
    };

    var result_chart = $("#result_chart")[0].getContext("2d");
    window.myPie = new Chart(result_chart).Pie(pieData, pieOptions);

    var legend = myPie.generateLegend();
    $("#legend").html(legend);
  };
}
