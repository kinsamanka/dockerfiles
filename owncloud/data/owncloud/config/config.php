<?php
$CONFIG = array(
  'datadirectory' => '/DATA/data',
  'apps_path' => array (
    0 => array (
      "path" => OC::$SERVERROOT."/apps",
      "url" => "/apps",
      "writable" => false,
    ),
    1 => array (
      "path" => "/DATA/apps",
      "url" => "/my_apps",
      "writable" => true,
    ),
  ),
  'version' => '8.1.5',
  'dbname' => 'owncloud',
  'dbhost' => 'OC_postgres',
  'dbuser' => 'mycloud',
  'installed' => false,
  'loglevel' => '0',
);
?>
