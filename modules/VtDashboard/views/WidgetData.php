<?php
/*+******************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 *******************************************************************************/

/**
 * Lazy-loads a single Report's data for a VtDashboard widget.
 * Returns a JSON envelope:
 *   chart report  -> { kind: 'chart', chartType, labels, datasets, indexAxis, title }
 *   tabular/summary -> { kind: 'table', html, count, title }
 *   on error      -> { kind: 'error', message }
 */
class VtDashboard_WidgetData_View extends Vtiger_IndexAjax_View {

    const ROW_LIMIT = 50;

    public function checkPermission(Vtiger_Request $request) {
        $currentUserPrivilegesModel = Users_Privileges_Model::getCurrentUserPrivilegesModel();
        $reportsModuleModel = Vtiger_Module_Model::getInstance('Reports');
        if (!$currentUserPrivilegesModel->hasModulePermission($reportsModuleModel->getId())) {
            throw new AppException(vtranslate('LBL_PERMISSION_DENIED'));
        }
        return true;
    }

    public function process(Vtiger_Request $request) {
        $response = new Vtiger_Response();
        $reportId = $request->get('reportid');

        // Buffer report generation so any stray PHP notices/warnings emitted by
        // the Reports engine cannot corrupt the JSON response body.
        ob_start();
        try {
            $result = $this->getWidgetData($reportId);
        } catch (Exception $e) {
            $result = array('kind' => 'error', 'message' => $e->getMessage());
        }
        ob_end_clean();

        $response->setResult($result);
        $response->emit();
    }

    /**
     * @param <Number> $reportId
     * @return <Array> JSON-serialisable widget payload
     */
    protected function getWidgetData($reportId) {
        if (empty($reportId)) {
            return array('kind' => 'error', 'message' => vtranslate('LBL_PERMISSION_DENIED'));
        }

        $reportModel = Reports_Record_Model::getInstanceById($reportId);
        if (empty($reportModel) || empty($reportModel->getId())) {
            return array('kind' => 'error', 'message' => vtranslate('LBL_PERMISSION_DENIED'));
        }

        // Sharing access check
        $currentUserPrivilegesModel = Users_Privileges_Model::getCurrentUserPrivilegesModel();
        $owner = $reportModel->get('owner');
        $sharingType = $reportModel->get('sharingtype');
        if (($currentUserPrivilegesModel->getId() != $owner) && $sharingType == 'Private') {
            if (!$reportModel->isRecordHasViewAccess($sharingType)) {
                return array('kind' => 'error', 'message' => vtranslate('LBL_PERMISSION_DENIED'));
            }
        }

        // Module level DetailView permission
        $primaryModule = $reportModel->getPrimaryModule();
        $moduleModel = Vtiger_Module_Model::getInstance($primaryModule);
        if (!$moduleModel || !$moduleModel->isPermitted('DetailView')) {
            return array(
                'kind'    => 'error',
                'message' => vtranslate($primaryModule, $primaryModule) . ' ' . vtranslate('LBL_NOT_ACCESSIBLE', 'Reports'),
            );
        }

        $title = decode_html($reportModel->getName()) . ' (' . vtranslate($primaryModule, $primaryModule) . ')';

        if ($reportModel->getReportType() == 'chart') {
            return $this->getChartData($reportModel, $title);
        }
        return $this->getTableData($reportModel, $title);
    }

    /**
     * Normalises a chart report into a Chart.js friendly structure.
     */
    protected function getChartData($reportModel, $title) {
        $chartModel = Reports_Chart_Model::getInstanceById($reportModel);
        $chartType = $chartModel->getChartType();
        $data = $chartModel->getData();

        $labels = isset($data['labels']) ? array_values($data['labels']) : array();
        $values = isset($data['values']) ? array_values($data['values']) : array();

        $datasets = array();
        if (!empty($values) && isset($values[0]) && is_array($values[0])) {
            // Multi/single series bar chart: values is an array of rows.
            $seriesLabels = isset($data['data_labels']) ? array_values($data['data_labels']) : array();
            $seriesCount = php7_count($values[0]);
            for ($s = 0; $s < $seriesCount; $s++) {
                $seriesData = array();
                foreach ($values as $row) {
                    $seriesData[] = isset($row[$s]) ? (float) $row[$s] : 0;
                }
                $datasets[] = array(
                    'label' => isset($seriesLabels[$s]) ? decode_html($seriesLabels[$s]) : '',
                    'data'  => $seriesData,
                );
            }
        } else {
            $flat = array();
            foreach ($values as $value) {
                $flat[] = (float) $value;
            }
            $datasets[] = array(
                'label' => isset($data['graph_label']) ? decode_html($data['graph_label']) : '',
                'data'  => $flat,
            );
        }

        $indexAxis = 'x';
        switch ($chartType) {
            case 'pieChart':
                $chartjsType = 'pie';
                break;
            case 'lineChart':
                $chartjsType = 'line';
                break;
            case 'horizontalbarChart':
                $chartjsType = 'bar';
                $indexAxis = 'y';
                break;
            case 'verticalbarChart':
            default:
                $chartjsType = 'bar';
                break;
        }

        return array(
            'kind'      => 'chart',
            'chartType' => $chartjsType,
            'labels'    => $labels,
            'datasets'  => $datasets,
            'indexAxis' => $indexAxis,
            'title'     => $title,
            'hasData'   => !empty($labels),
        );
    }

    /**
     * Returns the rendered (HTML) table for a tabular/summary report.
     */
    protected function getTableData($reportModel, $title) {
        $pagingModel = new Vtiger_Paging_Model();
        $pagingModel->set('page', 1);
        $pagingModel->set('limit', self::ROW_LIMIT);

        $reportModel->setModule('Reports');
        $reportData = $reportModel->getReportData($pagingModel);

        $rows = isset($reportData['data']) ? $reportData['data'] : array();
        $count = isset($reportData['count']) ? $reportData['count'] : 0;
        $html = $this->buildTableHtml($rows);

        return array(
            'kind'    => 'table',
            'html'    => $html,
            'count'   => $count,
            'title'   => $title,
            'hasData' => !empty($html),
        );
    }

    /**
     * Builds an HTML table from report data rows.
     * Report data is an array of rows, each row an associative array keyed by
     * the column label; values are already display-formatted (may contain HTML).
     * @param <Array> $rows
     * @return <String>
     */
    protected function buildTableHtml($rows) {
        if (empty($rows) || !is_array($rows) || empty($rows[0]) || !is_array($rows[0])) {
            return '';
        }

        $headers = array_keys($rows[0]);

        $html = '<table class="table table-bordered report-widget-table"><thead><tr>';
        foreach ($headers as $header) {
            $html .= '<th nowrap>' . $header . '</th>';
        }
        $html .= '</tr></thead><tbody>';

        foreach ($rows as $row) {
            $html .= '<tr>';
            foreach ($row as $value) {
                $html .= '<td>' . $value . '</td>';
            }
            $html .= '</tr>';
        }
        $html .= '</tbody></table>';

        return $html;
    }
}
