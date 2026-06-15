<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    .vtdashboard-workspace { padding: 20px; background-color: #f5f5f7; min-height: 85vh; }
    .vtdashboard-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #e2e8f0; }
    
    .header-left-group { display: flex; align-items: center; gap: 15px; }
    .board-select { padding: 6px 12px; font-size: 15px; font-weight: 600; border: 1px solid #cbd5e0; border-radius: 4px; background: #fff; color: #1a202c; cursor: pointer; }
    
    .widget-control-btn { background: #fff; border: 1px solid #cbd5e0; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 13px; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; }
    .widget-control-btn:hover { background: #f7fafc; }
    
    .widget-dropdown { position: relative; display: inline-block; }
    .widget-menu { display: none; position: absolute; right: 0; background: #fff; min-width: 260px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; border-radius: 4px; z-index: 100; padding: 6px 0; }
    .widget-menu.show { display: block; }
    .widget-menu-item { padding: 8px 16px; font-size: 13px; color: #4a5568; cursor: pointer; display: flex; align-items: center; justify-content: space-between; }
    .widget-menu-item:hover { background-color: #f7fafc; }
    .widget-menu-item.disabled { opacity: 0.5; cursor: not-allowed; background-color: #edf2f7; }
    
    /* Responsive Flex Engine Layouts */
    .dashboard-container { display: flex; flex-direction: column; gap: 20px; }
    .charts-row { display: flex; flex-wrap: wrap; gap: 20px; width: 100%; }
    .chart-col { flex: 1; min-width: 450px; }
    
    /* Widget Card Objects */
    .dashboard-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); display: none; }
    .dashboard-card.visible { display: block; }
    .card-header { background-color: #ffffff; padding: 12px 16px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
    .card-header.dark { background-color: #1a1a1a; color: #fff; }
    .card-title { font-size: 14px; font-weight: 600; color: #2d3748; margin: 0; }
    .card-header.dark .card-title { color: #fff; }
    
    .header-right { font-size: 13px; color: #718096; display: flex; gap: 14px; align-items: center; }
    .header-right i { cursor: pointer; transition: color 0.2s; }
    .header-right i:hover { color: #3182ce; }
    .card-header.dark .header-right i:hover { color: #ffe17d; }
    
    .chart-wrapper { padding: 20px; display: flex; flex-direction: column; align-items: center; justify-content: center; }
    .chart-container-box { position: relative; width: 100%; max-width: 480px; height: 340px; }
</style>

<div class="v7-content-card vtdashboard-workspace">
    <div class="vtdashboard-header">
        <div class="header-left-group">
            <i class="fa fa-columns fa-lg text-muted"></i>
            <select id="boardSwitcher" class="board-select">
                <option value="default">Default Dashboard</option>
                <option value="contact_centre">Contact Centre Manager</option>
            </select>
        </div>
        
        <div>
            <button class="widget-control-btn" id="resetDashboardBtn" style="margin-right: 8px;">
                <i class="fa fa-undo"></i> Reset Board
            </button>
            <div class="widget-dropdown">
                <button class="widget-control-btn" id="addWidgetMenuBtn">
                    <i class="fa fa-plus"></i> Add Widget To Board
                </button>
                <div class="widget-menu" id="widgetMenu">
                    {foreach from=$WIDGET_REGISTRY key=WIDGET_KEY item=WIDGET_INFO}
                        <div class="widget-menu-item" data-widget="{$WIDGET_KEY}" id="menu-item-{$WIDGET_KEY}">
                            <span><i class="fa {$WIDGET_INFO.icon} fa-fw"></i> {$WIDGET_INFO.title}</span>
                            <i class="fa fa-plus-circle text-success"></i>
                        </div>
                    {/foreach}
                </div>
            </div>
        </div>
    </div>

    <div class="dashboard-container">
        <div id="widget-performance_table" class="dashboard-card" style="width: 100%;">
            <div class="card-header">
                <h3 class="card-title">Resolution Unit Performance - Open Tickets (Tickets)</h3>
                <div class="header-right">
                    <i class="fa fa-sync-alt"></i>
                    <i class="fa fa-times close-widget" data-target="performance_table"></i>
                </div>
            </div>
            {include file="layouts/v7/modules/VtDashboard/widgets/PerformanceTable.tpl"}
        </div>

        <div class="charts-row">
            <div id="widget-service_area_chart" class="chart-col dashboard-card">
                <div class="card-header dark">
                    <h3 class="card-title">Service Area Distribution of Tickets (Tickets)</h3>
                    <div class="header-right">
                        <span>Refreshed: 1:44 PM</span>
                        <i class="fa fa-times close-widget" data-target="service_area_chart"></i>
                    </div>
                </div>
                <div class="chart-wrapper">
                    <div class="chart-container-box">
                        <canvas id="serviceAreaPieChart"></canvas>
                    </div>
                </div>
            </div>

            <div id="widget-sla_chart" class="chart-col dashboard-card">
                <div class="card-header dark">
                    <h3 class="card-title">SLA Performance (Tickets)</h3>
                    <div class="header-right">
                        <span>Refreshed: 12:56 PM</span>
                        <i class="fa fa-times close-widget" data-target="sla_chart"></i>
                    </div>
                </div>
                <div class="chart-wrapper">
                    <div class="chart-container-box">
                        <canvas id="slaPerformanceChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <div class="charts-row">
            <div id="widget-call_volume" class="chart-col dashboard-card">
                <div class="card-header">
                    <h3 class="card-title">Inbound Call Volume Trends</h3>
                    <div class="header-right">
                        <i class="fa fa-times close-widget" data-target="call_volume"></i>
                    </div>
                </div>
                <div class="chart-wrapper">
                    <div class="chart-container-box">
                        <canvas id="callVolumeLineChart"></canvas>
                    </div>
                </div>
            </div>

            <div id="widget-agent_status" class="chart-col dashboard-card">
                <div class="card-header">
                    <h3 class="card-title">Agent Status Distribution</h3>
                    <div class="header-right">
                        <i class="fa fa-times close-widget" data-target="agent_status"></i>
                    </div>
                </div>
                <div class="chart-wrapper">
                    <div class="chart-container-box">
                        <canvas id="agentStatusDoughnutChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const boardsConfig = {$BOARDS_CONFIG};
    const switcher = document.getElementById('boardSwitcher');
    
    function getActiveBoardKey() { return switcher.value; }

    function getBoardLayout() {
        const boardKey = getActiveBoardKey();
        const saved = localStorage.getItem('vt-board-layout-' + boardKey);
        return saved ? JSON.parse(saved) : boardsConfig[boardKey].widgets;
    }

    function saveBoardLayout(widgetsList) {
        const boardKey = getActiveBoardKey();
        localStorage.setItem('vt-board-layout-' + boardKey, JSON.stringify(widgetsList));
        renderActiveBoard();
    }

    function renderActiveBoard() {
        const activeWidgets = getBoardLayout();
        
        document.querySelectorAll('.dashboard-card[id^="widget-"]').forEach(card => {
            const widgetKey = card.id.replace('widget-', '');
            if (activeWidgets.includes(widgetKey)) {
                card.classList.add('visible');
            } else {
                card.classList.remove('visible');
            }
        });

        document.querySelectorAll('.widget-menu-item').forEach(item => {
            const widgetKey = item.getAttribute('data-widget');
            if (activeWidgets.includes(widgetKey)) {
                item.classList.add('disabled');
                item.style.pointerEvents = 'none';
            } else {
                item.classList.remove('disabled');
                item.style.pointerEvents = 'auto';
            }
        });
    }

    switcher.addEventListener('change', renderActiveBoard);

    const menuBtn = document.getElementById('addWidgetMenuBtn');
    const menu = document.getElementById('widgetMenu');
    menuBtn.addEventListener('click', (e) => { e.stopPropagation(); menu.classList.toggle('show'); });
    document.addEventListener('click', () => menu.classList.remove('show'));

    document.querySelectorAll('.widget-menu-item').forEach(item => {
        item.addEventListener('click', function() {
            const target = this.getAttribute('data-widget');
            let current = getBoardLayout();
            if (!current.includes(target)) {
                current.push(target);
                saveBoardLayout(current);
            }
        });
    });

    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('close-widget')) {
            const target = e.target.getAttribute('data-target');
            let current = getBoardLayout();
            current = current.filter(item => item !== target);
            saveBoardLayout(current);
        }
    });

    document.getElementById('resetDashboardBtn').addEventListener('click', () => {
        const boardKey = getActiveBoardKey();
        localStorage.removeItem('vt-board-layout-' + boardKey);
        renderActiveBoard();
    });

    renderActiveBoard();

    // Chart.js Context Canvas Rendering Calls
    new Chart(document.getElementById('serviceAreaPieChart').getContext('2d'), {
        type: 'pie',
        data: {
            labels: ['E-channels : 17%', 'Failed Transaction : 15%', 'Account Management : 11%', 'Others : 57%'],
            datasets: [{ data: [17, 15, 11, 57], backgroundColor: ['#ffe099', '#4cd4ca', '#4d7361', '#e6e6e6'] }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });

    new Chart(document.getElementById('slaPerformanceChart').getContext('2d'), {
        type: 'pie',
        data: {
            labels: ['Blank value : 41%', 'Fulfilled : 47%', 'Time Left : 12%'],
            datasets: [{ data: [41, 47, 12], backgroundColor: ['#ff8a98', '#ffb373', '#ffe17d'] }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });

    new Chart(document.getElementById('callVolumeLineChart').getContext('2d'), {
        type: 'line',
        data: {
            labels: ['9 AM', '11 AM', '1 PM', '3 PM', '5 PM'],
            datasets: [{ label: 'Calls Received', data: [65, 120, 190, 140, 85], borderColor: '#3182ce', tension: 0.2 }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });

    new Chart(document.getElementById('agentStatusDoughnutChart').getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: ['Available', 'On Call', 'Break', 'Offline'],
            datasets: [{ data: [14, 22, 5, 8], backgroundColor: ['#48bb78', '#3182ce', '#ecc94b', '#a0aec0'] }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });
});
</script>
