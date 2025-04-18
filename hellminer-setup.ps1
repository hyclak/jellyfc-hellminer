# Hellminer Setup on Windows for JellyFC Pool
$pool_url = "stratum+tcp://verus.jellyfc.com:3092"

# Determine Processor Funtionality and download the appropriate optimization
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Kernel32 {
    [DllImport("kernel32.dll")]
    public static extern bool IsProcessorFeaturePresent(int ProcessorFeature);
}
"@

$avx2Available = [Kernel32]::IsProcessorFeaturePresent(40) # PF_AVX2_INSTRUCTIONS_AVAILABLE
$avxAvailable = [Kernel32]::IsProcessorFeaturePresent(39) # PF_AVX_INSTRUCTIONS_AVAILABLE

if ($avx2Available) {
    $hellminer_url = "https://github.com/hellcatz/hminer/releases/download/v0.59.1/hellminer_win64_avx2.zip"
} elseif ($avxAvailable) {
    $hellminer_url = "https://github.com/hellcatz/hminer/releases/download/v0.59.1/hellminer_win64_avx.zip"
} else {
    $hellminer_url = "https://github.com/hellcatz/hminer/releases/download/v0.59.1/hellminer_win64.zip"
}

$num_cores = [Environment]::ProcessorCount

# Ask user for their wallet
$verus_wallet = Read-Host @"
Please enter your Verus Wallet 
You may include a workername after a period (e.g. veruswallet.$env:computername)
"@

Write-Output ""

# Ask user how many cores to reserve?
$reserve_cores = Read-Host @"
Your system has $num_cores CPU Cores.
How many would you like to reserve for normal operation? (Default is reserve 1 core)
"@

if ([string]::IsNullOrWhiteSpace($reserve_cores)) {
    $reserve_cores = "1"
}

$cpu_cores = $num_cores - $reserve_cores

# Display information
Write-Output @"

**********************************************************************************
Downloading $hellminer_url.
Installing to $env:LocalAppData\Hellminer.
Configuring Pool to $pool_url.
Configuring Wallet as $verus_wallet.
Configuring $cpu_cores CPU Cores for mining.
**********************************************************************************
"@

# Download miner to temp directory
Invoke-WebRequest $hellminer_url -OutFile $env:TEMP\hellminer.zip

# Create target Directory
New-Item -ItemType Directory -Path $env:LocalAppData\Hellminer -Force

# Extract Hellminer to the target directory
Expand-Archive -Path $env:TEMP\hellminer.zip -DestinationPath $env:LocalAppData\Hellminer -Force

# Configure Startup Batch File
".\hellminer.exe -c $pool_url -u $verus_wallet --cpu $cpu_cores -p x" | Out-File $env:LocalAppData\Hellminer\run_miner.ps1

# Create Scheduled Task to start on login for current user
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-file `"$env:LocalAppData\Hellminer\run_miner.ps1`"" -WorkingDirectory "$env:LocalAppData\Hellminer"
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
$trigger = New-ScheduledTaskTrigger -AtLogOn
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
Register-ScheduledTask -TaskName "JellyFC Launch Hellminer at Login" -InputObject $task -Force
