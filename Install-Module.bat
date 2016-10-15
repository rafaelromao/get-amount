SET modulespath="%homedrive%%homepath%\Documents\WindowsPowerShell\Modules\Get-Amount"
rd /s /q %modulespath%
md %modulespath%
copy *.ps?1 %modulespath%