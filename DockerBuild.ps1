# Enable strict mode to halt the script on any errors
Set-StrictMode -Version Latest

# Print the start message
Write-Host "Build Started"

# Define a function to execute commands and check for errors
function Run-Command {
    param($Command, $IsExternal = $false)
    try {
        if ($IsExternal) {
            & cmd /c $Command
        } else {
            & $Command
        }
        if ($LASTEXITCODE -ne 0) {
            throw "Command failed with exit code ${LASTEXITCODE}: $Command"
        }
    }
    catch {
        Write-Host "Error: $_"
        exit $LASTEXITCODE
    }
}

# Verify Docker daemon is accessible by running a simple Docker command
try {
    docker info | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to connect to Docker daemon. Please ensure Docker is running and try again."
        exit 1
    }
    Write-Host "Docker daemon is running."
} catch {
    Write-Host "Failed to connect to Docker daemon. Please ensure Docker is running and try again."
    exit 1
}

# Build the Flutter web
Run-Command "flutter build web" $true

# Build the Flutter APK
Run-Command "flutter build apk" $true

# Create MSIX package
#Run-Command "dart run msix:create" $true

# Build the Flutter Windows
Run-Command "flutter build windows" $true
$sourcePath = "build/windows/x64/runner/Release/*"
$destinationZip = "build/windows/x64/runner/Release/oes.zip"
if (Test-Path $destinationZip) {
    Remove-Item $destinationZip
}
Compress-Archive -Path $sourcePath -DestinationPath $destinationZip

# Build Docker image and push
Run-Command "docker buildx build --builder mybuilder --platform linux/amd64,linux/arm64,linux/arm/v7 -t sobotat/oes-web --push ." $true

# Notify that the build is finished
Run-Command { Invoke-WebRequest -Uri 'ntfy.sh/DockerSobotat' -Method POST -Body 'OES Build Finished' }

# Print the finish message
Write-Host "Build Finished"
