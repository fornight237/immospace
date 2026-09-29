param(
    [string]$Branch = 'ci-build-apk',
    [string]$Message = 'Prepare CI build APK artifact'
)

Write-Host "Adding changes..."
git add -A

Write-Host "Committing with message: $Message"
try {
    git commit -m $Message
} catch {
    Write-Host "No changes to commit or commit failed"
}

Write-Host "Pushing to origin/$Branch"
try {
    git push origin $Branch
} catch {
    Write-Host "Push failed. You may need to set upstream: git push -u origin $Branch"
}

Write-Host "Done."