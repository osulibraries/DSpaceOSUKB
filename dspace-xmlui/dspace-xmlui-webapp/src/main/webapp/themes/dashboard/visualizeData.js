//$(document).ready(function() {
    var dataValue = [];

    //Get all the data we need
    $('#aspect_dashboard_DashboardViewer_table_items_added_monthly tr.ds-table-row').each(function(){
        var rowDate = $(this).find('.date').html();
        var rowItemsAdded = $(this).find('.items_added').html();
        var rowItemsTotal = $(this).find('.items_total').html();
        dataValue.push([new Date(rowDate.substring(0,4), rowDate.substring(5,7), 1), rowItemsAdded*1, rowItemsTotal*1]);
    });

var total = 0;
    $('#aspect_dashboard_ElasticSearchStatsViewer_table_MonthlyDownloads tr.ds-table-row').each(function(){
        var rowDate = $(this).find('.date').html();
        var rowItemsAdded = $(this).find('.count').html();
        total = total + (rowItemsAdded*1);

        dataValue.push([new Date(rowDate.substring(0,4), rowDate.substring(5,7), 1), rowItemsAdded*1, total]);
    });



    //Build the google visualization
    google.load('visualization', '1',{'packages':['annotatedtimeline']});
    google.setOnLoadCallback(drawChart);
    function drawChart()
    {
        var data = new google.visualization.DataTable();
        data.addColumn('date', 'Date');
        data.addColumn('number', 'Items Added');
        data.addColumn('number', 'Total Items');
        data.addRows(dataValue);
        var chart = new google.visualization.AnnotatedTimeLine(document.getElementById('chart_div'));
        chart.draw(data, {displayAnnotations: true});
    }


//});