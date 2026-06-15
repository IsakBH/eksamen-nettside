<?php
session_start();
require 'db.php';

// Sjekk at vi er logget inn
if (!isset($_SESSION['bruker_id'])) {
    header("Location: index.php");
    exit;
}

$bruker_id = $_SESSION['bruker_id'];
$melding = "";

// UPDATE: Endre brukernavn
if (isset($_POST['oppdater_navn'])) {
    $nytt_navn = trim($_POST['nytt_navn']);

    $stmt = $conn->prepare("UPDATE brukere SET brukernavn = ? WHERE id = ?");
    $stmt->bind_param("si", $nytt_navn, $bruker_id);

    if ($stmt->execute()) {
        $_SESSION['brukernavn'] = $nytt_navn;
        $melding = "Brukernavn endret til $nytt_navn!";
    } else {
        $melding = "Feil! Kanskje navnet allerede er tatt?";
    }
    $stmt->close();
}

// DELETE: Slett bruker
if (isset($_POST['slett_bruker'])) {
    $stmt = $conn->prepare("DELETE FROM brukere WHERE id = ?");
    $stmt->bind_param("i", $bruker_id);
    $stmt->execute();
    $stmt->close();

    // Logg ut og send til forsiden
    session_destroy();
    header("Location: index.php");
    exit;
}

// READ: Hent brukerens nåværende info fra databasen
$stmt = $conn->prepare("SELECT brukernavn, rolle, adresse FROM brukere WHERE id = ?");
$stmt->bind_param("i", $bruker_id);
$stmt->execute();
$resultat = $stmt->get_result();
$bruker_data = $resultat->fetch_assoc();
$stmt->close();
?>
<!DOCTYPE html>
<html lang="no">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Grind FHS</title>
    <style>
        body { background: #121212; color: #e0e0e0; font-family: monospace, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
        .panel { background: #1e1e1e; padding: 20px; border: 1px solid #333; border-radius: 8px; margin-bottom: 20px; }
        input { padding: 10px; background: #2a2a2a; border: 1px solid #444; color: white; width: calc(100% - 22px); margin-bottom: 10px; }
        button { padding: 10px 15px; border: none; cursor: pointer; font-weight: bold; }
        .btn-update { background: #28a745; color: white; }
        .btn-update:hover { background: #218838; }
        .btn-danger { background: #dc3545; color: white; }
        .btn-danger:hover { background: #c82333; }
        .btn-logout { background: #555; color: white; text-decoration: none; padding: 10px 15px; display: inline-block; margin-top: 10px; }
        .msg { color: #5cff8a; }
    </style>
</head>
<body>

    <h1>Velkommen, <?= htmlspecialchars($bruker_data['brukernavn']) ?></h1>

    <div class="panel">
        <h3>Din Profil (Read)</h3>
        <p><strong>ID:</strong> <?= $bruker_id ?></p>
        <p><strong>Rolle:</strong> <?= htmlspecialchars($bruker_data['rolle']) ?></p>
        <p><strong>Adresse:</strong> <?= htmlspecialchars($bruker_data['adresse']) ?></p>
    </div>

    <div class="panel">
        <h3>Endre brukernavn (Update)</h3>
        <?php if($melding) echo "<p class='msg'>$melding</p>"; ?>
        <form method="POST">
            <input type="text" name="nytt_navn" value="<?= htmlspecialchars($bruker_data['brukernavn']) ?>" required>
            <button type="submit" name="oppdater_navn" class="btn-update">Lagre nytt navn</button>
        </form>
    </div>

    <div class="panel">
        <h3>Fare-sone (Delete)</h3>
        <form method="POST" onsubmit="return confirm('Er du helt sikker på at du vil slette brukeren din? Dette kan ikke angres.');">
            <button type="submit" name="slett_bruker" class="btn-danger">Slett Min Bruker</button>
        </form>
    </div>

    <a href="logout.php" class="btn-logout">Logg ut</a>

</body>
</html>