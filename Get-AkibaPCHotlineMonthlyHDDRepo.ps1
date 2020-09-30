<#
.SYNOPSIS
AKIBA PC Hotline!のHDD相場月報から、HDD単価を取得します。

.EXAMPLE
.\Get-AkibaPCHotlineMonthlyHDDRepo.ps1 https://akiba-pc.watch.impress.co.jp/docs/price/monthly_repo/1278493.html

.LINK
AKIBA PC Hotline!　相場月報
https://akiba-pc.watch.impress.co.jp/docs/price/monthly_repo/
#>
param(
    [Parameter(Mandatory=$true)][String]$Url,
    [Parameter( Mandatory = $false)]
    [ValidateSet("3.5インチHDD" , "2.5インチHDD")]
    [String]$Target = "3.5インチHDD"
)
Set-StrictMode -Version 5.1

$hddlist=@();
    
if( $url -eq $null -or -not ($url.StartsWith("https://akiba-pc.watch.impress.co.jp/docs/price/monthly_repo/"))) {

    Write-Warning "Not AKIBA PC Hotline! Url"

} else {

    $res = Invoke-WebRequest $url
    $tables = $res.ParsedHtml.getElementsByTagName("table")
    $tables | % {
        if($_.parentElement.parentElement.childNodes[0].innerText -eq $Target) {
            $_.rows | % {
                $model=$_.cells[0].innerText -replace"`n","";
                if($model -match"\((\d+)TB\)"){
                    [int]$price=$_.cells[2].innerText -replace",","";
                    $tb=[double]::Parse($Matches[1]);
                    $hddlist+=[PSCustomObject]@{
                        Model=$model;
                        CapacityTB=$tb;
                        Price=$price;
                        CostParTB=[Math]::Round(($price/$tb), [MidpointRounding]::AwayFromZero);
                    }
                }
            }
            return;
        }
    }
    if($hddlist.Count -eq 0){
        Write-Warning "Not Found $Target List";
    }
}
$hddlist
