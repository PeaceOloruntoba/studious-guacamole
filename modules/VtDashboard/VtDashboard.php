<?php
/*+**********************************************************************************
 * The contents of this file are subject to the vtiger CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  vtiger CRM Open Source
 * The Initial Developer of the Original Code is vtiger.
 * Portions created by vtiger are Copyright (C) vtiger.
 * All Rights Reserved.
 ************************************************************************************/
include_once 'modules/Vtiger/CRMEntity.php';

class VtDashboard extends CRMEntity {
    
    /**
     * Handle saving/editing of the module
     */
    function save_module($module) {
    }

    /**
     * Invoked when special actions are performed on the module.
     * @param String Module name
     * @param String Event Type (module.postinstall, module.disabled, etc)
     */
    function vtlib_handler($modulename, $event_type) {
        if($event_type == 'module.postinstall') {
            // TODO: Handle post installation tasks
        } else if($event_type == 'module.disabled') {
            // TODO: Handle actions before the module is being disabled.
        } else if($event_type == 'module.enabled') {
            // TODO: Handle actions when the module is being enabled.
        } else if($event_type == 'module.preuninstall') {
            // TODO: Handle actions when the module is about to be deleted.
        } else if($event_type == 'module.preupdate') {
            // TODO: Handle actions before the module is updated.
        } else if($event_type == 'module.postupdate') {
            // TODO: Handle actions after the module is updated.
        }
    }
}