# PowerShell script to test login endpoint
# Usage: .\test_login.ps1

$uri = "http://localhost:3000/api/auth/staff/login"
$body = @{
    staffId = "ADMIN001"
    password = "Admin@123"
} | ConvertTo-Json

try {
    Write-Host "Testing login endpoint..." -ForegroundColor Cyan
    Write-Host "URL: $uri" -ForegroundColor Gray
    Write-Host "Body: $body" -ForegroundColor Gray
    Write-Host ""
    
    $response = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body $body
    
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "❌ ERROR!" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Yellow
    
    # Try to get error details
    if ($_.ErrorDetails.Message) {
        Write-Host "Details:" -ForegroundColor Yellow
        $_.ErrorDetails.Message | ConvertFrom-Json | ConvertTo-Json -Depth 5
    }
}

