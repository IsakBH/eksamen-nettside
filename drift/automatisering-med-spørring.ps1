# Navn: Isak Brun Henriksen | Dato: 16.06.2026 | Formål: Automatisere oppretting av skoleårsmapper inni studieretningenes hovedmapper.

# 1. Spør brukeren om hvilket skoleår som skal opprettes
$Skoleaar = Read-Host -Prompt "Hvilket årstall gjelder dette for? (f.eks. 2026)"

# 2. Definer stien til hovedmappen på serveren
$SystemSti = "C:\Delte mapper"

# 3. Definer studieretningene/linjene (disse mappene må eksistere, eller så opprettes de på toppnivå)
$Linjer = @("Informasjonsteknologi", "Mediaproduksjon")

# 4. Definer hva som skal lages inni hver enkelt årsmappe
$Undermapper = @("Reiser", "planer", "økonomi")
$Filer = @("klasseliste.csv", "hendelser.txt", "logg.txt")

Write-Host "`nStarter oppretting for skoleåret: $Skoleaar..." -ForegroundColor Cyan

# --- Selve automatiseringen med løkker ---

foreach ($Linje in $Linjer) {

    # Definerer stien til selve linjemappen (f.eks. C:\Delte mapper\Informasjonsteknologi)
    $LinjeSti = Join-Path -Path $SystemSti -ChildPath $Linje

    # Sjekker om linjemappen eksisterer på toppnivå. Hvis ikke, opprettes den.
    if (-not (Test-Path -Path $LinjeSti)) {
        New-Item -Path $LinjeSti -ItemType Directory -Force | Out-Null
    }

    # NÅ: Definerer stien til årsmappen INNI linjemappen (f.eks. C:\Delte mapper\Informasjonsteknologi\2026)
    $AarsMappeSti = Join-Path -Path $LinjeSti -ChildPath $Skoleaar

    # Sjekker om årsmappen finnes fra før. Hvis ikke, opprettes den.
    if (-not (Test-Path -Path $AarsMappeSti)) {
        New-Item -Path $AarsMappeSti -ItemType Directory -Force | Out-Null
        Write-Host "Opprettet ny årsmappe: $Linje \$Skoleaar" -ForegroundColor Yellow
    } else {
        Write-Host "Årsmappen for $Linje \$Skoleaar eksisterer allerede. Sjekker innhold..." -ForegroundColor Gray
    }

    # Oppretter standard undermapper (Reiser, planer, økonomi) inni årsmappen
    foreach ($Mappe in $Undermapper) {
        $MappeSti = Join-Path -Path $AarsMappeSti -ChildPath $Mappe
        if (-not (Test-Path -Path $MappeSti)) {
            New-Item -Path $MappeSti -ItemType Directory -Force | Out-Null
            Write-Host "  -> Opprettet undermappe: \$Mappe" -ForegroundColor Green
        }
    }

    # Oppretter standarddokumentene (klasseliste, hendelser, logg) inni årsmappen
    foreach ($Fil in $Filer) {
        $FilSti = Join-Path -Path $AarsMappeSti -ChildPath $Fil
        if (-not (Test-Path -Path $FilSti)) {
            New-Item -Path $FilSti -ItemType File -Force | Out-Null
            Write-Host "  -> Opprettet fil:  $Fil" -ForegroundColor Green
        }
    }
}

Write-Host "`nAutomatisering fullført! Sjekk mappene dine i '$SystemSti'." -ForegroundColor Cyan