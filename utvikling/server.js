const express = require('express');
const sqlite3 = require('sqlite3').verbose();

const app = express();
app.use(express.json());
app.use(express.static('public'));

// --- DATABASE OPPSETT ---
const db = new sqlite3.Database('./skole.sqlite');

db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS brukere (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        navn TEXT,
        epost TEXT UNIQUE,
        passord TEXT,
        status TEXT
    )`);
});

// --- ENDEPUNKTER FOR AUTENTISERING ---

// 1. Registrering
app.post('/api/registrer', (req, res) => {
    const { navn, epost, passord } = req.body;

    if (!navn || !epost || !passord) {
        return res.status(400).json({ feil: "Alle felt må fylles ut." });
    }

    // Setter startstatus til 'registrert' når kontoen opprettes
    db.run("INSERT INTO brukere (navn, epost, passord, status) VALUES (?, ?, ?, 'registrert')",
    [navn, epost, passord], function(err) {
        if (err) {
            if (err.message.includes('UNIQUE')) {
                return res.status(400).json({ feil: "E-posten er allerede registrert." });
            }
            return res.status(500).json({ feil: "Databasefeil ved registrering." });
        }
        res.json({ melding: "Bruker registrert! Du kan nå logge inn." });
    });
});

// 2. Innlogging
app.post('/api/login', (req, res) => {
    const { epost, passord } = req.body;

    db.get("SELECT * FROM brukere WHERE epost = ? AND passord = ?", [epost, passord], (err, bruker) => {
        if (err) return res.status(500).json({ feil: "Databasefeil." });
        if (!bruker) return res.status(401).json({ feil: "Feil e-post eller passord." });

        // Returnerer brukeren (uten passordet for sikkerhetsskyld)
        res.json({
            melding: "Innlogging vellykket!",
            bruker: { id: bruker.id, navn: bruker.navn, epost: bruker.epost, status: bruker.status }
        });
    });
});

// 3. Hent gjeldende status for en innlogget bruker
app.get('/api/bruker/:id', (req, res) => {
    db.get("SELECT id, navn, epost, status FROM brukere WHERE id = ?", [req.params.id], (err, bruker) => {
        if (err || !bruker) return res.status(404).json({ feil: "Bruker ikke funnet." });
        res.json(bruker);
    });
});


// --- ENDEPUNKTER FOR SKOLEPROSESSEN ---

// 4. Melde interesse
app.post('/api/interesse/:id', (req, res) => {
    db.run("UPDATE brukere SET status = 'interessert' WHERE id = ? AND status = 'registrert'", [req.params.id], function(err) {
        if (err) return res.status(500).json({ feil: "Databasefeil." });
        res.json({ melding: "Du har nå meldt interesse for skolen!" });
    });
});

// 5. Søke opptak (Simulert e-postkvittering)
app.post('/api/soknad/:id', (req, res) => {
    db.get("SELECT * FROM brukere WHERE id = ?", [req.params.id], (err, bruker) => {
        if (!bruker) return res.status(404).json({ feil: "Bruker ikke funnet." });
        if (bruker.status !== 'interessert') return res.status(400).json({ feil: "Du må melde interesse før du kan søke." });

        db.run("UPDATE brukere SET status = 'sokt' WHERE id = ?", [req.params.id], function(err) {
            if (err) return res.status(500).json({ feil: "Databasefeil." });
            console.log(`[SIMULERING] Kvittering sendt til: ${bruker.epost}`);
            res.json({ melding: "Søknad mottatt! En kvittering har blitt sendt til din e-post." });
        });
    });
});

// 6. Svare på tilbud (ja/nei)
app.post('/api/svar/:id', (req, res) => {
    const { svar } = req.body;
    const nyStatus = svar === 'ja' ? 'takket_ja' : 'takket_nei';

    db.run("UPDATE brukere SET status = ? WHERE id = ? AND status = 'sokt'", [nyStatus, req.params.id], function(err) {
        if (err) return res.status(500).json({ feil: "Databasefeil." });
        res.json({ melding: `Du har nå takket ${svar} til plassen.` });
    });
});

// 7. Slette bruker (Sikkerhetssjekk)
app.delete('/api/bruker/:id', (req, res) => {
    db.get("SELECT status FROM brukere WHERE id = ?", [req.params.id], (err, bruker) => {
        if (err || !bruker) return res.status(404).json({ feil: "Bruker ikke funnet." });

        // KRAV: "Folk som har takket ja... skal ikke kunne slette brukeren sin..."
        if (bruker.status === 'takket_ja') {
            return res.status(403).json({
                feil: "Det er ikke lov å slette brukeren! Siden du har takket ja til å begynne, må vi ta vare på dataene dine."
            });
        }

        // KRAV: "Folk som takker nei... skal kunne slette brukeren sin."
        // Vi tillater sletting for takket_nei (og de som eventuelt ombestemmer seg tidlig i prosessen)
        db.run("DELETE FROM brukere WHERE id = ?", [req.params.id], function(err) {
            if (err) return res.status(500).json({ feil: "Kunne ikke slette brukeren." });
            return res.json({ melding: "Brukeren din er nå slettet fra systemet." });
        });
    });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Server kjører på http://localhost:${PORT}`));