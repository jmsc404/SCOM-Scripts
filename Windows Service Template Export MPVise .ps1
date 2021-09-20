$ALLMP = Get-SCOMManagementPack

foreach ($MP in $ALLMP){#Processing for each MP

$AllServices = @()
$MPName = $MP.DisplayName

$ServiceStateProbe = $null

$ServiceStateProbe = $MP.GetClasses() | ?{ $_.Name -match "ServiceStateProb*" -and $_.Base.getElement().DisplayName -eq "Windows Service"} 

#Getting Each Instance
$services = $null
$services = $ServiceStateProbe | Get-SCOMClassInstance

Foreach($Service in $services){ #Processing Each service instance

    $Sname = ($service | Select -ExpandProperty '`[Microsoft.SystemCenter.NTService].ServiceName').value
    $SProcess = ($service | Select -ExpandProperty '`[Microsoft.SystemCenter.NTService].ServiceProcessName').Value
    $SDisplayName = ($service | Select -ExpandProperty '`[Microsoft.SystemCenter.NTService].DisplayName').Value
    $SDescription = ($service | Select -ExpandProperty '`[Microsoft.SystemCenter.NTService].Description').Value
    $ServerName = ($service | Select -ExpandProperty '`[Microsoft.Windows.Computer].PrincipalName').Value

    #Storing details in custom MP
    $ServiceDetails = [PSCustomObject]@{
        ManagementPack = $MP.DisplayName
        ServerName = $ServerName
        ServiceName = $Sname
        ProcessName = $SProcess
        ServiceDisplayName = $SDisplayName
        ServiceDescription = $SDescription
    }

    $AllServices += $ServiceDetails

}#end Services
if($AllServices.Count -ge 1){
$MPName = $MPName.Replace("\","_")

#Change you Path here
$AllServices | Export-csv -Path "D:\Jags\Templete\ServiceTempleteDetails_$($MPName).csv" -NoTypeInformation -Force
}
}#end MP Loop
