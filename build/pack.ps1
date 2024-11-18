$ErrorActionPreference = "Stop"

$isGithub = [string]::IsNullOrEmpty($Env:GITHUB_ACTION) -eq $false
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

$pkgPath = ([io.path]::combine($root, "*.nupkg"))
Remove-Item $pkgPath

$ver_path = ([io.path]::combine($buildDir, "pkg.version"))
$ver = Get-Content -Path $ver_path
$key = $Env:MYGET_APIKEY
$myget = "https://www.myget.org/F/huoshan12345/api/v2/package"

if ([string]::IsNullOrEmpty($key)) {
  throw "the api key is empty"
}
if ([string]::IsNullOrEmpty($ver)) {
  throw "the version is empty"
}
$srcPath = [io.path]::combine($root, "..", "src")
$path = [io.path]::combine($srcPath, "InterfaceBaseInvoke")

Write-Output "Packing $($path.Basename)"
& dotnet clean $path --nologo -v q
& dotnet pack $path --nologo -v q -c Release --include-symbols --output $root -p:PackageVersion=$ver
if ($Lastexitcode -ne 0)	{
  throw "failed with exit code $LastExitCode"
}
Write-Output "Packing finished."

if ($isGithub) {
  Write-Output "Uploading..."

  $files = Get-ChildItem $pkgPath
  foreach ($file in $files) {
    Write-Output "Uploading $($file.Basename)"
    & dotnet nuget push $file -k $key --source $myget -t 50
    if ($Lastexitcode -ne 0) {
      throw "failed with exit code $LastExitCode"
    }
  }

  Write-Output "Uploading finished."
}
else {
  foreach ($project in $projects) {
    Write-Output "Removing $($project.Basename) from nuget cache"
    $packageLocalDir = [io.path]::combine( $env:USERPROFILE, ".nuget", "packages", $project.Basename.ToLower(), $ver);
    Remove-Item $packageLocalDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}