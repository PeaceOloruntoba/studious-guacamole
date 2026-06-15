<?php
/*+******************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *******************************************************************************/

class VtDashboard_Index_View extends Vtiger_Index_View {

    // 1. Tell Vtiger to include the header bar and sidebars
    public function preProcess(Vtiger_Request $request, $display = true) {
        parent::preProcess($request, $display);
    }

    public function process(Vtiger_Request $request) {
        $viewer = $this->getViewer($request);
        $moduleName = $request->getModule();

        list($widgetRegistry, $boards, $menuGroups) = $this->getReportBoards();

        $viewer->assign('WIDGET_REGISTRY', $widgetRegistry);
        $viewer->assign('MENU_GROUPS', $menuGroups);
        $viewer->assign('BOARDS_CONFIG', Zend_Json::encode($boards));
        $viewer->assign('MODULE', $moduleName);

        // 2. Just render the body fragment; Vtiger takes care of the wrapper
        $viewer->view('Index.tpl', $moduleName);
    }

    // 3. Close the global layout wrapper gracefully
    public function postProcess(Vtiger_Request $request) {
        parent::postProcess($request);
    }

    /**
     * Builds the widget registry and board layout from the user's accessible Reports.
     * Each report becomes a widget; each report folder becomes a board (plus an "All" board).
     * @return array [$widgetRegistry, $boards]
     */
    protected function getReportBoards() {
        $pagingModel = new Vtiger_Paging_Model();
        $pagingModel->set('page', 1);
        $pagingModel->set('limit', 1000);

        $folderModel = Reports_Folder_Model::getInstance();
        $folderModel->set('folderid', 'All');
        $folderModel->set('orderby', 'reportname');
        $folderModel->set('sortby', 'ASC');
        $reportModels = $folderModel->getReports($pagingModel);

        $widgetRegistry = array();
        $folderWidgets = array();
        $folderTitles = array();
        $allWidgets = array();
        $menuGroups = array();

        foreach ($reportModels as $reportModel) {
            $reportId = $reportModel->getId();
            if (empty($reportId)) {
                continue;
            }
            $reportType = $reportModel->getReportType();
            $isChart = ($reportType == 'chart');
            $primaryModule = $reportModel->get('primarymodule');
            $folderId = $reportModel->get('folderid');
            $folderName = $reportModel->get('foldername');
            if (empty($folderName)) {
                $folderName = vtranslate('LBL_REPORTS', 'Reports');
            }

            $widgetKey = (string) $reportId;
            $widgetRegistry[$widgetKey] = array(
                'title'  => decode_html($reportModel->getName()),
                'type'   => $isChart ? 'chart' : 'table',
                'module' => $primaryModule,
                'folder' => decode_html($folderName),
                'icon'   => $isChart ? 'fa-chart-pie' : 'fa-table',
            );

            $boardKey = 'folder_' . $folderId;
            if (!isset($folderWidgets[$boardKey])) {
                $folderWidgets[$boardKey] = array();
                $folderTitles[$boardKey] = decode_html($folderName);
            }
            $folderWidgets[$boardKey][] = $widgetKey;
            $allWidgets[] = $widgetKey;

            $groupName = decode_html($folderName);
            if (!isset($menuGroups[$groupName])) {
                $menuGroups[$groupName] = array();
            }
            $menuGroups[$groupName][$widgetKey] = $widgetRegistry[$widgetKey];
        }

        $boards = array(
            'all' => array(
                'title'   => vtranslate('LBL_ALL_REPORTS', 'VtDashboard'),
                'widgets' => $allWidgets,
            ),
        );
        foreach ($folderWidgets as $boardKey => $widgets) {
            $boards[$boardKey] = array(
                'title'   => $folderTitles[$boardKey],
                'widgets' => $widgets,
            );
        }

        return array($widgetRegistry, $boards, $menuGroups);
    }
}
