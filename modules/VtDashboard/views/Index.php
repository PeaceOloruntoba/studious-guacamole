<?php
/*+**********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 ************************************************************************************/

class VtDashboard_Index_View extends Vtiger_View_Controller {
    
    // 1. Tell Vtiger to include the header bar and sidebars
    public function preProcess(Vtiger_Request $request, $display = true) {
        parent::preProcess($request, $display);
    }

    public function process(Vtiger_Request $request) {
        $viewer = $this->getViewer($request);
        $moduleName = $request->getModule();

        $widgetRegistry = [
            'performance_table' => ['title' => 'Resolution Unit Performance', 'icon' => 'fa-table'],
            'service_area_chart' => ['title' => 'Service Area Distribution', 'icon' => 'fa-chart-pie'],
            'sla_chart' => ['title' => 'SLA Performance', 'icon' => 'fa-chart-pie'],
            'call_volume' => ['title' => 'Inbound Call Volume (CC)', 'icon' => 'fa-phone'],
            'agent_status' => ['title' => 'Agent Availability (CC)', 'icon' => 'fa-users']
        ];

        $boards = [
            'default' => [
                'title' => 'Default Dashboard',
                'widgets' => ['performance_table', 'service_area_chart', 'sla_chart']
            ],
            'contact_centre' => [
                'title' => 'Contact Centre Manager',
                'widgets' => ['call_volume', 'agent_status', 'performance_table']
            ]
        ];

        $viewer->assign('WIDGET_REGISTRY', $widgetRegistry);
        $viewer->assign('BOARDS_CONFIG', json_encode($boards));
        $viewer->assign('MODULE', $moduleName);

        // 2. Just render the body fragment; Vtiger takes care of the wrapper
        $viewer->view('Index.tpl', $moduleName);
    }

    // 3. Close the global layout wrapper gracefully
    public function postProcess(Vtiger_Request $request) {
        parent::postProcess($request);
    }
}
