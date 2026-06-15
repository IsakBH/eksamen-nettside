<?php
session_start();
require 'db.php';

// Send brukeren rett til dashboard hvis de allerede er logget inn
if (isset($_SESSION['bruker_id'])) {
    header("Location: dashboard.php");
    exit;
}

$melding = "";

// REGISTRERING (Create)
if (isset($_POST['registrer'])) {
    $brukernavn = trim($_POST['brukernavn']);
    $passord = password_hash($_POST['passord'], PASSWORD_DEFAULT);
    $rolle = "Elev"; // Default rolle
    $adresse = ""; // Blank by default

    // Sjekk om brukeren eksisterer
    $sjekk = $conn->prepare("SELECT id FROM brukere WHERE brukernavn = ?");
    $sjekk->bind_param("s", $brukernavn);
    $sjekk->execute();
    $sjekk->store_result();

    if ($sjekk->num_rows > 0) {
        $melding = "Brukernavnet er allerede tatt.";
    } else {
        $stmt = $conn->prepare("INSERT INTO brukere (brukernavn, passord, rolle, adresse) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $brukernavn, $passord, $rolle, $adresse);

        if ($stmt->execute()) {
            $melding = "Bruker opprettet! Du kan nå logge inn.";
        } else {
            $melding = "Noe gikk galt under registrering.";
        }
        $stmt->close();
    }
    $sjekk->close();
}

// INNLOGGING
if (isset($_POST['logg_inn'])) {
    $brukernavn = trim($_POST['brukernavn']);
    $passord = $_POST['passord'];

    $stmt = $conn->prepare("SELECT id, brukernavn, passord FROM brukere WHERE brukernavn = ?");
    $stmt->bind_param("s", $brukernavn);
    $stmt->execute();
    $resultat = $stmt->get_result();

    if ($bruker = $resultat->fetch_assoc()) {
        // Sjekk hashet passord
        if (password_verify($passord, $bruker['passord'])) {
            $_SESSION['bruker_id'] = $bruker['id'];
            $_SESSION['brukernavn'] = $bruker['brukernavn'];
            header("Location: dashboard.php");
            exit;
        } else {
            $melding = "Feil passord.";
        }
    } else {
        $melding = "Fant ikke brukeren.";
    }
    $stmt->close();
}
?>
<!DOCTYPE html>
<html lang="no">
<head>
    <meta charset="UTF-8">
    <title>Login - Grind FHS</title>
    <style>
        body { background: #121212; color: #e0e0e0; font-family: monospace, sans-serif; display: flex; justify-content: center; margin-top: 100px; }
        .boks { background: #1e1e1e; padding: 30px; border-radius: 8px; width: 300px; border: 1px solid #333; margin: 10px; }
        input { width: 100%; padding: 10px; margin: 10px 0; background: #2a2a2a; border: 1px solid #444; color: white; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #007acc; color: white; border: none; cursor: pointer; font-weight: bold; }
        button:hover { background: #005f9e; }
        .msg { color: #ff5c5c; margin-bottom: 15px; }
    </style>
</head>
<body>
    <div class="boks">
        <h2>Logg inn</h2>
        <?php if($melding) echo "<p class='msg'>$melding</p>"; ?>
        <form method="POST">
            <input type="text" name="brukernavn" placeholder="Brukernavn" required>
            <input type="password" name="passord" placeholder="Passord" required>
            <button type="submit" name="logg_inn">Logg inn</button>
        </form>
    </div>

    <div class="boks">
        <h2>Registrer</h2>
        <form method="POST">
            <input type="text" name="brukernavn" placeholder="Nytt brukernavn" required>
            <input type="password" name="passord" placeholder="Passord" required>
            <button type="submit" name="registrer">Opprett bruker</button>
        </form>
    </div>
</body>
</html>