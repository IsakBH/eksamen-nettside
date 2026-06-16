# Navn: Isak Brun Henriksen | Dato: 16.06.2026 | Formål: Automatisere oppretting av skoleårsmapper inni studieretningenes hovedmapper.

# dette spør brukeren om hvilket skoleår dette gjelder for, så liksom, hvilket skoleår den skal lage mappe for. hvis du skriver 2026, så får du en mappe som heter "2026", og inni den mappen ligger da alle filene som klasseliste.csv, hendelser.txt, osv. skikkelig tøft ikke sant!!
$Skoleaar = Read-Host -Prompt "Hvilket årstall gjelder dette for? (f.eks. 2026)"

# dette definerer hvilken mappe scriptet skal kjøre i. du kan si dette er "working directoryet" til scriptet
$SystemSti = "C:\Delte mapper"

# dette definerer studieretningene, eller, linjene, som scriptet skal ta utgangspunkt i. scriptet sjekker senere om de eksisterer, og hvis de ikke gjør det så lager den de.
$Linjer = @("Informasjonsteknologi", "Mediaproduksjon")

# her har du noen arrays med filer og mapper som skal lages av scriptet. senere i scriptet bruker den foreach loops som går igjennom for hvert element og lager mappen.
$Undermapper = @("Reiser", "planer", "økonomi")
$Filer = @("klasseliste.csv", "hendelser.txt", "logg.txt")

# dette er bare en simpel write-host funksjon, som basically bare printer ut til skjermen. du kan sammenligne det med en console.log i javascript, eller en echo/print i PHP.
Write-Host "`nStarter oppretting for skoleåret: $Skoleaar..." -ForegroundColor Cyan

# her har du hoved delen av scriptet som går igjennom hver linje og faktisk lager filene

foreach ($Linje in $Linjer) {

    # dette er bare filstien til linje mappen. f.eks 'c:\delte mapper\informasjonsteknologi' og sånn.
    $LinjeSti = Join-Path -Path $SystemSti -ChildPath $Linje

    # dette er en sjekk for å se om linje mappen eksisterer. hvis ikke så lager den den.
    if (-not (Test-Path -Path $LinjeSti)) {
        New-Item -Path $LinjeSti -ItemType Directory -Force | Out-Null
    }

    # dette er bare en variabel som slår sammen linje stien, som da er noe som 'c:\delte mapper\informasjonsteknologi' med skoleåret, som da gjør at resultatet blir f.eks 'c:\delte mapper\informasjonsteknologi\2026'.
    $AarsMappeSti = Join-Path -Path $LinjeSti -ChildPath $Skoleaar

    # sjekker om året allerede finnes inni mappen. hvis den ikke gjør det så lager den det jo :D
    if (-not (Test-Path -Path $AarsMappeSti)) {
        New-Item -Path $AarsMappeSti -ItemType Directory -Force | Out-Null
        Write-Host "Opprettet ny årsmappe: $Linje \$Skoleaar" -ForegroundColor Yellow
    } else {
        Write-Host "Årsmappen for $Linje \$Skoleaar eksisterer allerede. Sjekker innhold..." -ForegroundColor Gray
    }

    # lager mappene reiser, planer og økonomi inni årsmappen (f.eks 2026). denne foreach loopen går bare igjennom hvert entry i undermapper arrayen og executer koden under for hvert element.
    foreach ($Mappe in $Undermapper) {
        $MappeSti = Join-Path -Path $AarsMappeSti -ChildPath $Mappe
        if (-not (Test-Path -Path $MappeSti)) {
            New-Item -Path $MappeSti -ItemType Directory -Force | Out-Null
            Write-Host "  -> Opprettet undermappe: \$Mappe" -ForegroundColor Green
        }
    }

    # denne foreach loopen lager dokumentene og filene klasseliste.csv, hendelser.txt og logg.txt.
    foreach ($Fil in $Filer) {
        $FilSti = Join-Path -Path $AarsMappeSti -ChildPath $Fil
        if (-not (Test-Path -Path $FilSti)) {
            New-Item -Path $FilSti -ItemType File -Force | Out-Null
            Write-Host "  -> Opprettet fil:  $Fil" -ForegroundColor Green
        }
    }
}

Write-Host "`nAutomatisering fullført! Sjekk mappene dine i '$SystemSti'." -ForegroundColor Cyan