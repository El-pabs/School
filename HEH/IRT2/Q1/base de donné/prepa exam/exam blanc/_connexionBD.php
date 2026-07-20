<?php
date_default_timezone_set('Europe/Brussels');
$hote = 'localhost';
$nomBD = 'exam 2020';
$user = 'root';
$password = '';

try {
	$bd = new PDO('mysql:host='.$hote.';dbname='.$nomBD, $user, $password);
	$bd->exec("SET NAMES 'utf8'");
}
catch (Exception $e) {
	echo 'Erreur de connexion à la BD : ',$e;
}