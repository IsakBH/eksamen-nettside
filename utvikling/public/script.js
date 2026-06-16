let loggetInnBruker = JSON.parse(localStorage.getItem('skoleBruker')) || null;

// Funksjon som gjemmer forsiden og viser registreringen når man trykker på knappen
function visRegistrering() {
    document.getElementById('hjemSone').classList.add('hidden');
    document.getElementById('authSone').classList.remove('hidden');
    document.getElementById('statusMelding').classList.add('hidden');
}

// Funksjon for å gå tilbake til forsiden
function visHjemmeside() {
    document.getElementById('hjemSone').classList.remove('hidden');
    document.getElementById('authSone').classList.add('hidden');
    document.getElementById('statusMelding').classList.add('hidden');
}

// Styrer hva som er synlig basert på om man er logget inn eller ikke
async function oppdaterSoneVisning() {
    const hjemSone = document.getElementById('hjemSone');
    const authSone = document.getElementById('authSone');
    const dashboardSone = document.getElementById('dashboardSone');

    if (!loggetInnBruker) {
        // Hvis ikke logget inn, vis den vanlige hjemmesiden med knappen
        hjemSone.classList.remove('hidden');
        authSone.classList.add('hidden');
        dashboardSone.classList.add('hidden');
        return;
    }

    // Hvis logget inn, hent status fra backend og tilpass dashboardet
    try {
        const res = await fetch(`/api/bruker/${loggetInnBruker.id}`);
        if (!res.ok) { loggUt(); return; }
        const bruker = await res.json();

        hjemSone.classList.add('hidden');
        authSone.classList.add('hidden');
        dashboardSone.classList.remove('hidden');

        document.getElementById('velkomstNavn').innerText = bruker.navn;
        document.getElementById('brukerStatus').innerText = bruker.status.toUpperCase();

        document.getElementById('stegInteresse').classList.add('hidden');
        document.getElementById('stegSoknad').classList.add('hidden');
        document.getElementById('stegSvar').classList.add('hidden');

        if (bruker.status === 'registrert') {
            document.getElementById('stegInteresse').classList.remove('hidden');
        } else if (bruker.status === 'interessert') {
            document.getElementById('stegSoknad').classList.remove('hidden');
        } else if (bruker.status === 'sokt') {
            document.getElementById('stegSvar').classList.remove('hidden');
        }
    } catch (err) {
        console.error(err);
    }
}

// Registrering
async function registrerBruker() {
    const navn = document.getElementById('regNavn').value;
    const epost = document.getElementById('regEpost').value;
    const passord = document.getElementById('regPassord').value;

    const res = await fetch('/api/registrer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ navn, epost, passord })
    });
    const data = await res.json();
    visMelding(data.melding, data.feil);
}

// Innlogging
async function loggInn() {
    const epost = document.getElementById('loginEpost').value;
    const passord = document.getElementById('loginPassord').value;

    const res = await fetch('/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ epost, passord })
    });
    const data = await res.json();

    if (res.ok) {
        loggetInnBruker = data.bruker;
        localStorage.setItem('skoleBruker', JSON.stringify(data.bruker));
        document.getElementById('statusMelding').classList.add('hidden');
        oppdaterSoneVisning();
    } else {
        visMelding(null, data.feil);
    }
}

function loggUt() {
    loggetInnBruker = null;
    localStorage.removeItem('skoleBruker');
    oppdaterSoneVisning();
}

async function meldInteresse() {
    const res = await fetch(`/api/interesse/${loggetInnBruker.id}`, { method: 'POST' });
    const data = await res.json();
    visMelding(data.melding, data.feil);
    oppdaterSoneVisning();
}

async function sendSoknad() {
    const res = await fetch(`/api/soknad/${loggetInnBruker.id}`, { method: 'POST' });
    const data = await res.json();
    visMelding(data.melding, data.feil);
    oppdaterSoneVisning();
}

async function svarTilbud(svarType) {
    const res = await fetch(`/api/svar/${loggetInnBruker.id}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ svar: svarType })
    });
    const data = await res.json();
    visMelding(data.melding, data.feil);
    oppdaterSoneVisning();
}

async function sletteBruker() {
    const res = await fetch(`/api/bruker/${loggetInnBruker.id}`, { method: 'DELETE' });
    const data = await res.json();

    if (res.ok) {
        visMelding(data.melding, null);
        loggUt();
    } else {
        visMelding(null, data.feil); // Her vises "Ikke lov"-meldingen i rødt hvis man har takket ja
    }
}

function visMelding(suksessTekst, feilTekst) {
    const boks = document.getElementById('statusMelding');
    boks.classList.remove('hidden', 'alert-success', 'alert-danger');
    if (feilTekst) {
        boks.innerText = feilTekst;
        boks.classList.add('alert-danger');
    } else if (suksessTekst) {
        boks.innerText = suksessTekst;
        boks.classList.add('alert-success');
    }
}

// Sjekk status ved oppstart
oppdaterSoneVisning();