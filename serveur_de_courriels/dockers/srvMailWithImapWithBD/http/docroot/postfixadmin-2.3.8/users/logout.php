<?php
/** 
 * Postfix Admin 
 * 
 * LICENSE 
 * This source file is subject to the GPL license that is bundled with  
 * this package in the file LICENSE.TXT. 
 * 
 * Further details on the project are available at : 
 *     http://www.postfixadmin.com or http://postfixadmin.sf.net 
 * 
 * @version $Id: logout.php 566 2009-02-15 15:02:26Z christian_boltz $ 
 * @license GNU GPL v2 or later. 
 * 
 * File: logout.php
 * De-authenticates a user.
 *
 * Template File: -none-
 *
 * Template Variables: -none-
 *
 * Form POST \ GET Variables: -none-
 */

require_once('../common.php');

session_unset ();
session_destroy ();

header ("Location: login.php");
exit;

/* vim: set expandtab softtabstop=4 tabstop=4 shiftwidth=4: */
?>
