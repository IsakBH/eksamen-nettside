<?php
$host = "localhost";
$user = "isak";
$pass = "some_pass";
$dbname = "eksamen";

// Opprett tilkobling med mysqli
$conn = new mysqli($host, $user, $pass, $dbname);

// Sjekk tilkobling
if ($conn->connect_error) {
    die("Krasj! Tilkobling feilet: " . $conn->connect_error);
}

// Sett tegnsett for å unngå trøbbel med æøå
$conn->set_charset("utf8mb4");
?>