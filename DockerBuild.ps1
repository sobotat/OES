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

# Build the Flutter web
Run-Command "flutter build web" $true

# Build the Flutter APK
Run-Command "flutter build apk" $true

# Create MSIX package
Run-Command "dart run msix:create" $true

# Build Docker image and push
Run-Command "docker buildx build --builder mybuilder --platform linux/amd64,linux/arm64,linux/arm/v7 -t sobotat/oes-web --push ." $true

# Notify that the build is finished
Run-Command { Invoke-WebRequest -Uri 'ntfy.sh/DockerSobotat' -Method POST -Body 'OES Build Finished' }

# Print the finish message
Write-Host "Build Finished"
