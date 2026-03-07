<#
.SYNOPSIS
    Menampilkan semua password WiFi yang pernah terhubung di Windows.
.DESCRIPTION
    Script ini membaca profil WiFi yang tersimpan menggunakan netsh,
    lalu menampilkan SSID dan password (Key Content) untuk setiap profil.
.NOTES
    - Jalankan script ini dengan hak administrator untuk hasil maksimal.
    - Output tergantung pada bahasa sistem (script ini dioptimalkan untuk bahasa Inggris).
#>

# Bersihkan layar
Clear-Host

Write-Host "=== WiFi Password Viewer ===" -ForegroundColor Cyan
Write-Host "Mengambil daftar profil WiFi..." -ForegroundColor Cyan

# Ambil semua profil WiFi
$profilesRaw = netsh wlan show profiles
$profiles = $profilesRaw | Select-String ":\s+(.+)$" | ForEach-Object {
    $_.Matches.Groups[1].Value.Trim()
}

if ($profiles.Count -eq 0) {
    Write-Host "Tidak ada profil WiFi yang ditemukan." -ForegroundColor Yellow
    exit
}

Write-Host "Ditemukan $($profiles.Count) profil WiFi." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Cyan

foreach ($profile in $profiles) {
    Write-Host "Profil WiFi : " -NoNewline; Write-Host "$profile" -ForegroundColor White
    
    # Ambil detail profil termasuk password (key=clear)
    $details = netsh wlan show profile name="$profile" key=clear
    
    # Cari baris yang mengandung "Key Content"
    $passwordLine = $details | Select-String "Key Content\s+:\s+(.+)$"
    
    if ($passwordLine) {
        $password = $passwordLine.Matches.Groups[1].Value.Trim()
        Write-Host "Password    : " -NoNewline; Write-Host "$password" -ForegroundColor Green
    } else {
        Write-Host "Password    : " -NoNewline; Write-Host "<tidak ditemukan / tersembunyi>" -ForegroundColor Gray
    }
    Write-Host "----------------------------------------" -ForegroundColor Cyan
}

Write-Host "Selesai." -ForegroundColor Cyan
