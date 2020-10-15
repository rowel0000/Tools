<#
.SYNOPSIS
	Terraria公式サイトからTerrariaServerをダウンロードして展開します
    展開後、TerrariaServerのカレントディレクトリに移動します

.PARAMETER $ServerDir
    TerrariaServerの展開先
    規定値 C:\TerrariaServer

.PARAMETER ServerDir
    TerrariaServerの展開先
    規定値 C:\TerrariaServer
	
.PARAMETER ArchivesDir
    規定値 ${ServerDir}\archives

.PARAMETER TerrariaUrl
    Terraria 公式サイト　URL
    規定値 https://terraria.org/

.EXAMPLE
	.\Get-TerrariaServer.ps1
#>

[CmdletBinding()]
Param(
	[Parameter (Mandatory=$false)]
	[String]$ServerDir = "C:\TerrariaServer",

	[Parameter (Mandatory=$false)]
	[String]$ArchivesDir  = (Join-Path $ServerDir "archives"),

	[Parameter (Mandatory=$false)]
	[String]$TerrariaUrl = "https://terraria.org/"
)
$ErrorActionPreference = "Stop"


# 保存先がなければ作成
if(-not (Test-Path -PathType Container -Path $ServerDir))
{
    New-Item -ItemType Directory $ServerDir
}
if(-not (Test-Path -PathType Container -Path $ArchivesDir))
{
    New-Item -ItemType Directory $ArchivesDir
}

# 公式サイトのトップページをダウンロード
$r = Invoke-WebRequest -UseBasicParsing -Uri $TerrariaUrl
# PC Dedicated Server のリンク先を探す
[uri]$downloadurl = ($r.Links | ? { $_.outerHTML -match ">PC Dedicated Server<" } | Select-Object -First 1).href -replace "^/+", $TerrariaUrl 

# リンク先が取得できたかチェック
if($downloadurl.AbsolutePath -eq $null)
{
    Write-Error "ダウンロードリンクが見つかりません`n"
}
else 
{
    # 保存先のパス組み立て
    $downloadFilePath = (Join-Path $ArchivesDir $downloadurl.Segments[-1])
    # ダウンロード済みのファイルがないかチェック
    if(-not (Test-Path  -PathType Leaf -Path $downloadFilePath))
    {
        # Terraria-Server-????.zipをダウンロード
        Invoke-WebRequest $downloadurl -OutFile $downloadFilePath
        # Terraria Server保存先ディレクトリ以下に展開
        # (バージョン番号のフォルダに入った状態で圧縮されているので、そのまま展開)
        Expand-Archive -Path $downloadFilePath -DestinationPath $ServerDir
    }
    # 保存したファイルから、バージョン番号部分を取り出し
    if( $downloadFilePath -match "terraria-server-(\d+).zip")
    {
        # OS 別に cd先を切り替える
        $os = "Windows"
        $exec = ".\TerrariaServer.exe"
        if( $PSVersionTable.PSVersion.Major -ge 6)
        {
            if($isMac)
            {
                Write-Error "Not implementation"
                throw
            }
            elseif($isLinux)
            {
                Write-Error "Not implementation"
                throw
            }
        }
        Set-Location (Join-Path $ServerDir  $Matches[1] | Join-Path -ChildPath $os)
        Start-Process  $exec 
    }
}
