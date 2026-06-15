<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    .vtdashboard-workspace { padding: 20px; background-color: #f5f5f7; min-height: 85vh; }
    .vtdashboard-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #e2e8f0; }

    .header-left-group { display: flex; align-items: center; gap: 15px; }
    .board-select { padding: 6px 12px; font-size: 15px; font-weight: 600; border: 1px solid #cbd5e0; border-radius: 4px; background: #fff; color: #1a202c; cursor: pointer; }

    .widget-control-btn { background: #fff; border: 1px solid #cbd5e0; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 13px; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; }
    .widget-control-btn:hover { background: #f7fafc; }

    .widget-dropdown { position: relative; display: inline-block; }
    .widget-menu { display: none; position: absolute; right: 0; background: #fff; min-width: 300px; max-height: 70vh; overflow-y: auto; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; border-radius: 4px; z-index: 100; padding: 6px 0; }
    .widget-menu.show { display: block; }
    .widget-menu-group-title { padding: 6px 16px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em; color: #a0aec0; }
    .widget-menu-item { padding: 8px 16px; font-size: 13px; color: #4a5568; cursor: pointer; display: flex; align-items: center; justify-content: space-between; }
    .widget-menu-item:hover { background-color: #f7fafc; }
    .widget-menu-item.disabled { opacity: 0.5; cursor: not-allowed; background-color: #edf2f7; }

    /* Responsive Flex Engine Layouts */
    .dashboard-container { display: flex; flex-wrap: wrap; gap: 20px; align-items: flex-start; }
    .dashboard-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); display: none; flex-direction: column; }
    .dashboard-card.visible { display: flex; }
    .dashboard-card.type-chart { flex: 1 1 450px; min-width: 450px; }
    .dashboard-card.type-table { flex: 1 1 100%; width: 100%; }

    .card-header { background-color: #ffffff; padding: 12px 16px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
    .card-title { font-size: 14px; font-weight: 600; color: #2d3748; margin: 0; }

    .header-right { font-size: 13px; color: #718096; display: flex; gap: 14px; align-items: center; }
    .header-right i { cursor: pointer; transition: color 0.2s; }
    .header-right i:hover { color: #3182ce; }

    .widget-body { padding: 16px; min-height: 120px; }
    .dashboard-card.type-chart .widget-body { display: flex; align-items: center; justify-content: center; }
    .chart-container-box { position: relative; width: 100%; max-width: 480px; height: 320px; }

    .widget-state { color: #a0aec0; font-size: 13px; padding: 30px 0; text-align: center; width: 100%; }
    .widget-state .fa { margin-right: 6px; }

    .report-table-scroll { overflow-x: auto; }
    .empty-board { color: #a0aec0; font-size: 15px; padding: 60px 0; text-align: center; width: 100%; }
</style>

<div class="v7-content-card vtdashboard-workspace">
    <div class="vtdashboard-header">
        <div class="header-left-group">
            <i class="fa fa-columns fa-lg text-muted"></i>
            <select id="boardSwitcher" class="board-select"></select>
        </div>

        <div>
            <button class="widget-control-btn" id="resetDashboardBtn" style="margin-right: 8px;">
                <i class="fa fa-undo"></i> {vtranslate('LBL_RESET_BOARD', $MODULE)}
            </button>
            <div class="widget-dropdown">
                <button class="widget-control-btn" id="addWidgetMenuBtn">
                    <i class="fa fa-plus"></i> {vtranslate('LBL_ADD_WIDGET_TO_BOARD', $MODULE)}
                </button>
                <div class="widget-menu" id="widgetMenu">
                    {if $MENU_GROUPS}
                        {foreach from=$MENU_GROUPS key=GROUP_NAME item=GROUP_ITEMS}
                            <div class="widget-menu-group-title">{$GROUP_NAME|escape}</div>
                            {foreach from=$GROUP_ITEMS key=WIDGET_KEY item=WIDGET_INFO}
                                <div class="widget-menu-item" data-widget="{$WIDGET_KEY}" id="menu-item-{$WIDGET_KEY}">
                                    <span><i class="fa {$WIDGET_INFO.icon} fa-fw"></i> {$WIDGET_INFO.title|escape}</span>
                                    <i class="fa fa-plus-circle text-success"></i>
                                </div>
                            {/foreach}
                        {/foreach}
                    {else}
                        <div class="widget-menu-item disabled"><span>{vtranslate('LBL_NO_REPORTS_AVAILABLE', $MODULE)}</span></div>
                    {/if}
                </div>
            </div>
        </div>
    </div>

    <div class="dashboard-container" id="dashboardContainer">
        {foreach from=$WIDGET_REGISTRY key=WIDGET_KEY item=WIDGET_INFO}
            <div id="widget-{$WIDGET_KEY}" class="dashboard-card type-{$WIDGET_INFO.type}" data-reportid="{$WIDGET_KEY}" data-type="{$WIDGET_INFO.type}">
                <div class="card-header">
                    <h3 class="card-title">{$WIDGET_INFO.title|escape}</h3>
                    <div class="header-right">
                        <i class="fa fa-sync-alt refresh-widget" title="{vtranslate('LBL_REFRESH', $MODULE)}" data-target="{$WIDGET_KEY}"></i>
                        <i class="fa fa-times close-widget" title="{vtranslate('LBL_REMOVE', $MODULE)}" data-target="{$WIDGET_KEY}"></i>
                    </div>
                </div>
                <div class="widget-body">
                    <div class="widget-state widget-placeholder"><i class="fa fa-spinner fa-spin"></i> {vtranslate('LBL_LOADING', $MODULE)}</div>
                </div>
            </div>
        {/foreach}
        <div class="empty-board" id="emptyBoardMsg" style="display:none;">{vtranslate('LBL_NO_WIDGETS_ON_BOARD', $MODULE)}</div>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const boardsConfig = {$BOARDS_CONFIG};
    const switcher = document.getElementById('boardSwitcher');
    const palette = ['#3182ce', '#48bb78', '#ecc94b', '#ed8936', '#9f7aea', '#38b2ac', '#f56565', '#4299e1', '#ed64a6', '#a0aec0'];
    const chartInstances = { };
    const loadedWidgets = { };

    // Populate board switcher from server config
    Object.keys(boardsConfig).forEach(function(key) {
        const opt = document.createElement('option');
        opt.value = key;
        opt.textContent = boardsConfig[key].title;
        switcher.appendChild(opt);
    });

    function getActiveBoardKey() { return switcher.value; }

    function getBoardLayout() {
        const boardKey = getActiveBoardKey();
        const saved = localStorage.getItem('vt-board-layout-' + boardKey);
        if (saved) { try { return JSON.parse(saved); } catch (e) { /* ignore */ } }
        return (boardsConfig[boardKey] && boardsConfig[boardKey].widgets) ? boardsConfig[boardKey].widgets.slice() : [];
    }

    function saveBoardLayout(widgetsList) {
        const boardKey = getActiveBoardKey();
        localStorage.setItem('vt-board-layout-' + boardKey, JSON.stringify(widgetsList));
        renderActiveBoard();
    }

    function widgetUrl(reportId) {
        return 'index.php?module=VtDashboard&view=WidgetData&reportid=' + encodeURIComponent(reportId);
    }

    function setState(card, html) {
        const body = card.querySelector('.widget-body');
        body.innerHTML = '<div class="widget-state">' + html + '</div>';
    }

    function renderChart(card, result) {
        const reportId = card.getAttribute('data-reportid');
        const body = card.querySelector('.widget-body');
        if (!result.hasData || !result.labels || result.labels.length === 0) {
            setState(card, '{vtranslate('LBL_NO_DATA', $MODULE)}');
            return;
        }
        body.innerHTML = '<div class="chart-container-box"><canvas></canvas></div>';
        const canvas = body.querySelector('canvas');
        if (chartInstances[reportId]) { chartInstances[reportId].destroy(); }

        const isCircular = (result.chartType === 'pie' || result.chartType === 'doughnut');
        const datasets = result.datasets.map(function(ds, i) {
            if (isCircular) {
                return { label: ds.label, data: ds.data, backgroundColor: result.labels.map(function(l, idx) { return palette[idx % palette.length]; }) };
            }
            const color = palette[i % palette.length];
            return { label: ds.label, data: ds.data, backgroundColor: color, borderColor: color, fill: false, tension: 0.2 };
        });

        chartInstances[reportId] = new Chart(canvas.getContext('2d'), {
            type: result.chartType,
            data: { labels: result.labels, datasets: datasets },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                indexAxis: result.indexAxis || 'x',
                plugins: { legend: { display: isCircular || result.datasets.length > 1, position: 'bottom' } }
            }
        });
    }

    function renderTable(card, result) {
        const body = card.querySelector('.widget-body');
        if (!result.hasData) {
            setState(card, '{vtranslate('LBL_NO_DATA', $MODULE)}');
            return;
        }
        body.innerHTML = '<div class="report-table-scroll">' + result.html + '</div>';
    }

    function loadWidget(card, force) {
        const reportId = card.getAttribute('data-reportid');
        if (!force && loadedWidgets[reportId]) { return; }
        loadedWidgets[reportId] = true;
        setState(card, '<i class="fa fa-spinner fa-spin"></i> {vtranslate('LBL_LOADING', $MODULE)}');

        fetch(widgetUrl(reportId), { credentials: 'same-origin', headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function(resp) { return resp.json(); })
            .then(function(json) {
                const result = json && json.result ? json.result : json;
                if (!result || result.kind === 'error') {
                    setState(card, '<i class="fa fa-exclamation-triangle"></i> ' + (result && result.message ? result.message : '{vtranslate('LBL_NO_DATA', $MODULE)}'));
                    return;
                }
                if (result.kind === 'chart') { renderChart(card, result); }
                else { renderTable(card, result); }
            })
            .catch(function() {
                loadedWidgets[reportId] = false;
                setState(card, '<i class="fa fa-exclamation-triangle"></i> {vtranslate('LBL_FAILED_TO_LOAD', $MODULE)}');
            });
    }

    function renderActiveBoard() {
        const activeWidgets = getBoardLayout();
        let visibleCount = 0;

        document.querySelectorAll('.dashboard-card[id^="widget-"]').forEach(function(card) {
            const widgetKey = card.getAttribute('data-reportid');
            if (activeWidgets.indexOf(widgetKey) !== -1) {
                card.classList.add('visible');
                visibleCount++;
                loadWidget(card, false);
            } else {
                card.classList.remove('visible');
            }
        });

        document.getElementById('emptyBoardMsg').style.display = visibleCount === 0 ? 'block' : 'none';

        document.querySelectorAll('.widget-menu-item[data-widget]').forEach(function(item) {
            const widgetKey = item.getAttribute('data-widget');
            if (activeWidgets.indexOf(widgetKey) !== -1) {
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
    menuBtn.addEventListener('click', function(e) { e.stopPropagation(); menu.classList.toggle('show'); });
    document.addEventListener('click', function() { menu.classList.remove('show'); });

    document.querySelectorAll('.widget-menu-item[data-widget]').forEach(function(item) {
        item.addEventListener('click', function() {
            if (this.classList.contains('disabled')) { return; }
            const target = this.getAttribute('data-widget');
            let current = getBoardLayout();
            if (current.indexOf(target) === -1) {
                current.push(target);
                saveBoardLayout(current);
            }
        });
    });

    document.addEventListener('click', function(e) {
        const closeBtn = e.target.closest ? e.target.closest('.close-widget') : null;
        if (closeBtn) {
            const target = closeBtn.getAttribute('data-target');
            let current = getBoardLayout().filter(function(item) { return item !== target; });
            saveBoardLayout(current);
            return;
        }
        const refreshBtn = e.target.closest ? e.target.closest('.refresh-widget') : null;
        if (refreshBtn) {
            const card = document.getElementById('widget-' + refreshBtn.getAttribute('data-target'));
            if (card) { loadWidget(card, true); }
        }
    });

    document.getElementById('resetDashboardBtn').addEventListener('click', function() {
        const boardKey = getActiveBoardKey();
        localStorage.removeItem('vt-board-layout-' + boardKey);
        renderActiveBoard();
    });

    renderActiveBoard();
});
</script>
