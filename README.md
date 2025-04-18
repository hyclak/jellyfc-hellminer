# jellyfc-hellminer
Configuration scripts for setting up Hellminer

## Windows

1. Start Powershell as an Administrator
2. Run hellminer-setup.ps1
3. Answer the questions
```powershell
PS C:\Users\Matthew Hyclak\scripts> .\hellminer-setup.ps1
Please enter your Verus Wallet
You may include a workername after a period (e.g. veruswallet.COMPUTERNAME): myveruswalletaddress.computername
Your system has 32 CPU Cores.
How many would you like to reserve for normal operation? (Default is reserve 1 core): 2

**********************************************************************************
Downloading https://github.com/hellcatz/hminer/releases/download/v0.59.1/hellminer_win64_avx2.zip.
Installing to C:\Users\Matthew Hyclak\AppData\Local\Hellminer.
Configuring Pool to stratum+tcp://verus.jellyfc.com:3092.
Configuring Wallet as myveruswalletaddress.computername.
Configuring 30 CPU Cores for mining.
**********************************************************************************
```

The script will create a scheduled task that runs at startup that will launch the run_miner.ps1 file located in the Installation Directory.
