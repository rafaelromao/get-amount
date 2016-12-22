# Parse the input arguments
function ParseArguments($input_args) {
	$result = New-Object System.Object
	$result | Add-Member -type NoteProperty -name debug -value $false
	$result | Add-Member -type NoteProperty -name printHelp -value $false
	$result | Add-Member -type NoteProperty -name initial_amount -value $null
	$result | Add-Member -type NoteProperty -name initial_date -value $null
	$result | Add-Member -type NoteProperty -name final_date -value $null
	$result | Add-Member -type NoteProperty -name anual_interest -value $null
	$result | Add-Member -type NoteProperty -name monthly_interest -value $null    
	$result | Add-Member -type NoteProperty -name anual_fee -value $null
	$result | Add-Member -type NoteProperty -name final_tax -value $null

	for ($i = 0; $i -lt $input_args.Length; $i++) {
		# Parse the current and next arguments
		$arg = $input_args[$i]
		$hasNextArg = $i -lt $input_args.Length-1
		$nextArg = $null
		if ($hasNextArg) {
			$nextArg = $input_args[$i+1]
		}

		if ($arg -eq "--debug" -or $arg -eq "-D") {
			$result.debug = $true
		}

		if ($arg -eq "--help" -or $arg -eq "-h") {
			$result.printHelp = $true
		}
		
		if ($arg -eq "--initial_amount" -or $arg -eq "-ia") {
			$result.initial_amount = "$($nextArg)"
		}
		
		if ($arg -eq "--initial_date" -or $arg -eq "-id") {
			$result.initial_date = "$($nextArg)"
		}

		if ($arg -eq "--final_date" -or $arg -eq "-fd") {
			$result.final_date = "$($nextArg)"
		}
		
		if ($arg -eq "--anual_interest" -or $arg -eq "-ai") {
			$result.anual_interest = "$($nextArg)"
		}

		if ($arg -eq "--monthly_interest" -or $arg -eq "-mi") {
			$result.monthly_interest = "$($nextArg)"
		}

		if ($arg -eq "--anual_fee" -or $arg -eq "-af") {
			$result.anual_fee = "$($nextArg)"
		}

		if ($arg -eq "--final_tax" -or $arg -eq "-ft") {
			$result.final_tax = "$($nextArg)"
		}
	}

	return $result
}

# Check if the arguments used require the help to be printed
function CheckIfMustPrintHelp($printHelp, $hasCommitMessage) {
	if ($printHelp) {
		Write-Host ""
		Write-Host "--help `t`t`t -h `t Print usage options"
		Write-Host "--initial_amount `t -ia `t Initial amount"
		Write-Host "--initial_date `t`t`t -id `t Initial date"
		Write-Host "--final_date `t`t -fd `t Final date"
		Write-Host "--anual_interest `t`t`t -ai `t Anual interest"
		Write-Host "--monthly_interest `t`t`t -mi `t monthly interest"
		Write-Host "--anual_fee `t`t`t -af `t Anual fee"
		Write-Host "--final_tax `t`t`t -ft `t Final tax"
		Write-Host ""
		return $true
	}
	return $false
}

# Check, request and store mandatory parameters
function CheckRequestAndStoreMandatoryParameters($arguments) {
	if ($arguments.initial_amount -eq $null) {
        Write-Host 'Informe your initial amount name: [Default = 5000]'
		$arguments.initial_amount = Read-Host;
	}
	if ([string]::IsNullOrEmpty($arguments.initial_amount)) { 
        $arguments.initial_amount = 5000
	}
    $defaultInitialDate = "{0:yyyy-MM-dd}" -f (get-date -f "yyyy-MM-dd");
	if ($arguments.initial_date -eq $null) {
		Write-Host 'Informe the initial date: [Default = ' $defaultInitialDate ']'
		$arguments.initial_date = Read-Host;
	}
	if ([string]::IsNullOrEmpty($arguments.initial_date)) {
        $arguments.initial_date = $defaultInitialDate;
	}
	if ($arguments.final_date -eq $null) {
		Write-Host 'Informe the final date: [Default = 1800]'
		$arguments.final_date = Read-Host;
	}
	if ([string]::IsNullOrEmpty($arguments.final_date)) {
		$arguments.final_date = 1800;
	}
    if (([string]($arguments.final_date)).IndexOf("-") -eq -1) {
        $arguments.final_date = "{0:yyyy-MM-dd}" -f ([DateTime]$arguments.initial_date).addDays([int]$arguments.final_date)
    }
	if (($arguments.anual_interest -eq $null) -and ($arguments.monthly_interest -eq $null)) {
		Write-Host 'Informe the anual interest: [Default = 14.00]'
		$arguments.anual_interest = Read-Host;
	}
	if ([string]::IsNullOrEmpty($arguments.anual_interest)) {
		$arguments.anual_interest = 14;
	}
	if ($arguments.anual_fee -eq $null) {
		Write-Host 'Informe the anual fee: [Default = 0.00]'
		$arguments.anual_fee = Read-Host;
	}
    if ([string]::IsNullOrEmpty($arguments.anual_fee)) {
		$arguments.anual_fee = 0;
	}
	if ($arguments.final_tax -eq $null) {
		Write-Host 'Informe the final tax: [Default = 0.00]'
		$arguments.final_tax = Read-Host;
	}
	if ([string]::IsNullOrEmpty($arguments.final_tax)) {
		$arguments.final_tax = 0;
	}

	if ($arguments.debug) {
		Write-Host ""
		Write-Host ($arguments | ConvertTo-Json)
		Write-Host ""
	}
	
	return $true
}

function GetAmountForArguments($arguments) {
	$timespan = ([DateTime]$arguments.final_date).subtract([DateTime]$arguments.initial_date)
	if ($arguments.debug) {
		Write-Host $timespan
	}
	$amount = [double]$arguments.initial_amount
	if ($arguments.debug) {
		Write-Host $amount
	}
	$totalMonths = $timespan.TotalDays / 30
	if ($arguments.debug) {
		Write-Host $totalMonths
	}
	for ($i = 0; $i -lt $totalMonths; $i++) {
        if ($arguments.monthly_interest -ne $null) {
            $amortization = $amount * [double]$arguments.monthly_interest / 100
        } else {
    		$amortization = $amount * [double]$arguments.anual_interest / 12 / 100
        }
		if ($arguments.debug) {
			Write-Host $amortization
		}
		$amount = $amount + $amortization
		if ($arguments.debug) {
			Write-Host $amount
		}
	}
	$totalYears = $timespan.TotalDays / 365
	if ($arguments.debug) {
		Write-Host $totalYears
	}
	$anualfee = $amount * $totalYears * [double]$arguments.anual_fee / 100
	if ($arguments.debug) {
		Write-Host $anualfee
	}
	$amount = $amount - $anualfee
	if ($arguments.debug) {
		Write-Host $amount
	}
	$finaltax = ($amount - [double]$arguments.initial_amount) * [double]$arguments.final_tax / 100
	if ($arguments.debug) {
		Write-Host $finaltax
	}
	$amount = $amount - $finaltax
	if ($arguments.debug) {
		Write-Host $amount
	}
	return $amount
}

function GetAmountForArgumentsValidating($arguments) {
	if ($arguments.debug) {
		Set-PSDebug -Trace 1
	}
	$help = CheckIfMustPrintHelp $arguments.printHelp $hasCommitMessage
	if ($help -ne $true) {
		$validated = CheckRequestAndStoreMandatoryParameters $arguments
		if ($validated -eq $true) {
			$result = GetAmountForArguments $arguments
			return $result
		}
	}
}

function Get-Amount() {
	Set-PSDebug -Off
	$arguments = ParseArguments $args
    $ids = GetAmountForArgumentsValidating $arguments
    return $ids
}
