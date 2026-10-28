# ==============================================================================
# QE Test Failure Triage Engine - Batch Execution & HTML Report Generator
# ==============================================================================

param(
    [string]$WebhookUrl = "http://localhost:5678/webhook/qe-test-triage",
    [string]$ReportPath = ".\QE_Test_Triage_Report.html"
)
# This runner checks HTTP acceptance only. Verify downstream routing separately.
# Running it can create Jira tasks, Slack messages, and Airtable records.


$testCases = @(
    @{
        id = "TC-001"
        expected = "Output 0 (Jira only in current export)"
        desc = "JVM Fatal OutOfMemory Crash"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1001",
  "environment": "DEMO-STAGING",
  "application": "Volta Web Storefront",
  "test_case_id": "TC-CRASH-001",
  "test_name": "Checkout_JVM_Fatal_OutOfMemoryError",
  "execution_status": "FAILED",
  "execution_time_ms": 1250,
  "error_type": "java.lang.OutOfMemoryError",
  "error_message": "FATAL: Java heap space exhausted in CheckoutService. Service crashed and container restarted unexpectedly.",
  "stack_trace": "java.lang.OutOfMemoryError: Java heap space\n\tat com.volta.checkout.OrderProcessor.allocateBuffer(OrderProcessor.java:214)"
}
'@
    },
    @{
        id = "TC-002"
        expected = "Output 0 (Jira only in current export)"
        desc = "Payment Gateway Timeout"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1002",
  "environment": "DEMO-STAGING",
  "application": "Volta Web Storefront",
  "test_case_id": "TC-PAYMENT-001",
  "test_name": "Checkout_Payment_Gateway_Timeout",
  "execution_status": "FAILED",
  "execution_time_ms": 31200,
  "error_type": "PaymentGatewayException",
  "error_message": "CRITICAL: Payment gateway timed out after 30000ms during transaction authorization.",
  "stack_trace": "PaymentGatewayException: Timeout of 30000ms exceeded during charge execution\n\tat com.volta.checkout.PaymentService.charge(PaymentService.java:142)"
}
'@
    },
    @{
        id = "TC-003"
        expected = "Output 0 (Jira only in current export)"
        desc = "Database Connection Pool Exhaustion"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1003",
  "environment": "DEMO-QA",
  "application": "Volta Order API",
  "test_case_id": "TC-DB-009",
  "test_name": "Postgres_ConnectionPool_Exhausted",
  "execution_status": "FAILED",
  "execution_time_ms": 15400,
  "error_type": "SQLException",
  "error_message": "FATAL: Cannot obtain database connection. Synthetic demo connection pool exhausted.",
  "stack_trace": "org.postgresql.util.PSQLException: FATAL: connection limit exceeded in synthetic demo database"
}
'@
    },
    @{
        id = "TC-004"
        expected = "Output 1 (Slack + Airtable)"
        desc = "Promo Discount Calculation Error"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1004",
  "environment": "DEMO-STAGING",
  "application": "Volta Web Storefront",
  "test_case_id": "TC-PROMO-008",
  "test_name": "Apply_Seasonal_Coupon_AUTUMN-ROAST",
  "execution_status": "FAILED",
  "execution_time_ms": 2410,
  "error_type": "AssertionError",
  "error_message": "Expected cart total to be '34.00 EUR' after 15% discount, but received '40.00 EUR'",
  "stack_trace": "AssertionError: Expected '34.00 EUR' but got '40.00 EUR'\n\tat com.volta.tests.web.CartTest.verifyPromoDiscount(CartTest.java:94)"
}
'@
    },
    @{
        id = "TC-005"
        expected = "Output 1 (Slack + Airtable)"
        desc = "Email Notification Service Failure"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1005",
  "environment": "DEMO-STAGING",
  "application": "Volta Notification Worker",
  "test_case_id": "TC-NOTIF-003",
  "test_name": "Send_Order_Confirmation_Email",
  "execution_status": "FAILED",
  "execution_time_ms": 5200,
  "error_type": "SMTPConnectException",
  "error_message": "Could not connect to SMTP host: smtp.example.invalid (synthetic demo host): simulated service unavailable",
  "stack_trace": "com.sun.mail.util.MailConnectException: Couldn't connect to host"
}
'@
    },
    @{
        id = "TC-006"
        expected = "Output 1 (Slack + Airtable)"
        desc = "User Profile Picture Upload Size Limit"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1006",
  "environment": "DEMO-DEV-QA",
  "application": "Volta Customer Portal",
  "test_case_id": "TC-USER-014",
  "test_name": "Upload_Profile_Avatar_JPEG",
  "execution_status": "FAILED",
  "execution_time_ms": 1800,
  "error_type": "MaxUploadSizeExceededException",
  "error_message": "Maximum upload size of 5MB exceeded for user avatar.",
  "stack_trace": "org.springframework.web.multipart.MaxUploadSizeExceededException: Maximum upload size exceeded"
}
'@
    },
    @{
        id = "TC-007"
        expected = "Output 2 (Airtable Only)"
        desc = "UI Alignment Assertion Failure"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1007",
  "environment": "DEMO-DEV-QA",
  "application": "Volta Web Storefront",
  "test_case_id": "TC-UI-002",
  "test_name": "Verify_Footer_Copyright_Year",
  "execution_status": "FAILED",
  "execution_time_ms": 890,
  "error_type": "ElementMismatchError",
  "error_message": "Expected footer element text '© 2026 Volta Roasters', but found '© 2025 Volta Roasters'",
  "stack_trace": "ElementMismatchError: Text mismatch at xpath '//footer/p[1]'"
}
'@
    },
    @{
        id = "TC-008"
        expected = "Output 2 (Airtable Only)"
        desc = "Flaky Network Intermittent Delay"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1008",
  "environment": "DEMO-DEV-QA",
  "application": "Volta Analytics Pipeline",
  "test_case_id": "TC-ANALYTICS-005",
  "test_name": "Track_Page_View_Event",
  "execution_status": "FAILED",
  "execution_time_ms": 3100,
  "error_type": "NetworkTimeoutException",
  "error_message": "Minor analytics ping failed to respond within 3000ms limit.",
  "stack_trace": "NetworkTimeoutException: Request timed out"
}
'@
    },
    @{
        id = "TC-009"
        expected = "Output 2 (Airtable Only)"
        desc = "Non-Critical Typo in Error Response"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1009",
  "environment": "DEMO-DEV-QA",
  "application": "Volta Search API",
  "test_case_id": "TC-SEARCH-011",
  "test_name": "Search_Invalid_Query_Validation",
  "execution_status": "FAILED",
  "execution_time_ms": 420,
  "error_type": "AssertionError",
  "error_message": "Expected error message 'Invalid search term', got 'Invalid Search Term'",
  "stack_trace": "AssertionError: Expected 'Invalid search term' but got 'Invalid Search Term'"
}
'@
    },
    @{
        id = "TC-010"
        expected = "Output 2 (Airtable Only)"
        desc = "CSS Animation Loading Order"
        body = @'
{
  "test_run_id": "TR-VOLTA-2026-1010",
  "environment": "DEMO-DEV-QA",
  "application": "Volta Web Storefront",
  "test_case_id": "TC-UI-089",
  "test_name": "Hero_Banner_Fade_In_Animation",
  "execution_status": "FAILED",
  "execution_time_ms": 1150,
  "error_type": "VisualRegressionException",
  "error_message": "Visual diff ratio 0.02% exceeds 0.00% threshold on hero banner animation frame.",
  "stack_trace": "VisualRegressionException: Frame visual snapshot mismatch"
}
'@
    }
)

$reportResults = @()
$startTime = Get-Date

Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host " Starting QE Triage Engine Batch Execution (10 Test Failures)" -ForegroundColor Cyan
Write-Host " Delay: 30 seconds between requests" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host ""

for ($i = 0; $i -lt $testCases.Count; $i++) {
    $test = $testCases[$i]
    $num = $i + 1
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    Write-Host "[$num/10] Sending $($test.id): $($test.desc)..." -ForegroundColor Yellow
    
    $status = "UNKNOWN"
    $responseMsg = ""

    try {
        $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -ContentType "application/json" -Body $test.body
        $status = "ACCEPTED"
        $responseMsg = "Webhook triggered successfully"
        Write-Host "      [SUCCESS] Request accepted by n8n Webhook." -ForegroundColor Green
    }
    catch {
        $status = "FAILED"
        $responseMsg = $_.Exception.Message
        Write-Host "      [FAILED] Could not send request: $_" -ForegroundColor Red
    }

    $reportResults += [PSCustomObject]@{
        TestID        = $test.id
        Description   = $test.desc
        ExpectedRoute = $test.expected
        Status        = $status
        Timestamp     = $timestamp
        Details       = $responseMsg
    }

    if ($num -lt $testCases.Count) {
        Write-Host "      Waiting 30 seconds before next request..." -ForegroundColor Gray
        Start-Sleep -Seconds 30
    }
}

$endTime = Get-Date
$duration = New-TimeSpan -Start $startTime -End $endTime

$acceptedCount = ($reportResults | Where-Object { $_.Status -eq "ACCEPTED" }).Count
$failedCount = ($reportResults | Where-Object { $_.Status -eq "FAILED" }).Count

$htmlRows = ""
foreach ($res in $reportResults) {
    $badgeClass = if ($res.Status -eq "ACCEPTED") { "badge-success" } else { "badge-danger" }
    $htmlRows += @"
        <tr>
            <td><strong>$($res.TestID)</strong></td>
            <td>$($res.Description)</td>
            <td><code>$($res.ExpectedRoute)</code></td>
            <td><span class="badge $badgeClass">$($res.Status)</span></td>
            <td>$($res.Timestamp)</td>
            <td>$($res.Details)</td>
        </tr>
"@
}

$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>QE Test Triage Engine Execution Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; color: #333; margin: 0; padding: 20px; }
        .container { max-width: 1100px; margin: 0 auto; background: #ffffff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        h1 { color: #1a2b4c; margin-bottom: 5px; font-size: 24px; }
        p.subtitle { color: #666; font-size: 14px; margin-top: 0; margin-bottom: 25px; }
        .summary-cards { display: flex; gap: 15px; margin-bottom: 25px; }
        .card { flex: 1; padding: 15px; border-radius: 6px; background: #f8f9fa; border-left: 4px solid #007bff; }
        .card h3 { margin: 0; font-size: 12px; text-transform: uppercase; color: #666; }
        .card p { margin: 5px 0 0 0; font-size: 20px; font-weight: bold; color: #1a2b4c; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { text-align: left; padding: 12px 15px; border-bottom: 1px solid #e1e1e1; font-size: 14px; }
        th { background-color: #f1f3f5; color: #495057; font-weight: 600; }
        tr:hover { background-color: #f8f9fa; }
        code { background: #e9ecef; padding: 2px 6px; border-radius: 4px; font-family: Consolas, monospace; font-size: 13px; color: #d63384; }
        .badge { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; display: inline-block; }
        .badge-success { background-color: #d4edda; color: #155724; }
        .badge-danger { background-color: #f8d7da; color: #721c24; }
        .footer { margin-top: 25px; font-size: 12px; color: #888; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚨 QE Test Failure Triage Engine</h1>
        <p class="subtitle">Automated Batch Execution Summary Report</p>
        
        <div class="summary-cards">
            <div class="card" style="border-color: #007bff;">
                <h3>Total Test Cases</h3>
                <p>$($reportResults.Count)</p>
            </div>
            <div class="card" style="border-color: #28a745;">
                <h3>Accepted Calls</h3>
                <p>$acceptedCount</p>
            </div>
            <div class="card" style="border-color: #dc3545;">
                <h3>Failed Calls</h3>
                <p>$failedCount</p>
            </div>
            <div class="card" style="border-color: #6c757d;">
                <h3>Total Duration</h3>
                <p>$($duration.Minutes)m $($duration.Seconds)s</p>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Test ID</th>
                    <th>Description</th>
                    <th>Expected Routing Path</th>
                    <th>Status</th>
                    <th>Timestamp</th>
                    <th>Details</th>
                </tr>
            </thead>
            <tbody>
                $htmlRows
            </tbody>
        </table>

        <div class="footer">
            Generated on $($endTime.ToString("yyyy-MM-dd HH:mm:ss")) | Volta Coffee Roasters QE Automation Pipeline
        </div>
    </div>
</body>
</html>
"@

$htmlContent | Out-File -FilePath $reportPath -Encoding utf8

Write-Host ""
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host " Batch Execution Completed!" -ForegroundColor Cyan
Write-Host " HTML Report generated: $reportPath" -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Cyan

Invoke-Item $reportPath