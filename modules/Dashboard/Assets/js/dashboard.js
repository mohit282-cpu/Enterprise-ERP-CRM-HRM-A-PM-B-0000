document.addEventListener('DOMContentLoaded', function() {
    // Fetch chart data via API
    fetch('/api/dashboard/charts/revenue')
        .then(response => response.json())
        .then(data => {
            var options = {
                series: data.series,
                chart: {
                    type: 'area',
                    height: 350,
                    toolbar: { show: false }
                },
                colors: ['#0d6efd', '#dc3545'],
                dataLabels: { enabled: false },
                stroke: { curve: 'smooth' },
                xaxis: {
                    categories: data.categories
                },
                tooltip: {
                    x: { format: 'dd/MM/yy HH:mm' }
                }
            };

            var chart = new ApexCharts(document.querySelector("#revenueChart"), options);
            chart.render();
        })
        .catch(error => console.error('Error loading chart data:', error));
});
