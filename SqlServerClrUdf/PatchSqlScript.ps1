
function ConvertFileToHexString{
	param (
		[Parameter(Mandatory=$true)][string]$inputDllFilename
	)

	$inputDllContent = Get-Content $inputDllFilename -Encoding Byte ` -ReadCount 0 

	$dllHexDump = "0x"

	foreach ( $byte in $inputDllContent ) {
		$dllHexDump += "{0:X2}" -f $byte
	}

	return $dllHexDump;
}

$outputSqlFilename = ".\FarmhashInstallation.sql"
$outputSqlContent = Get-Content $outputSqlFilename

$outputSqlContent = $outputSqlContent -replace '_FARMHASH_SHARP_DLL_HEX_', (ConvertFileToHexString ".\Farmhash.Sharp.dll")
$outputSqlContent = $outputSqlContent -replace '_FARMHASH_SHARP_PDB_HEX_', (ConvertFileToHexString ".\Farmhash.Sharp.pdb")
$outputSqlContent = $outputSqlContent -replace '_FARMHASH_SHARP_SQLSERVERCLRUDF_DLL_HEX_', (ConvertFileToHexString ".\SqlServerClrUdf.dll")
$outputSqlContent = $outputSqlContent -replace '_FARMHASH_SHARP_SQLSERVERCLRUDF_PDB_HEX_', (ConvertFileToHexString ".\SqlServerClrUdf.pdb")

$outputSqlContent | Set-Content -Path $outputSqlFilename
