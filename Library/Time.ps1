$script:StartTime = get-date

Function Set-StartTime{
    $script:StartTime = get-date
}

function Get-ElapsedTime {
    $runtime = $(get-date) - $script:SstartTime
    $return_string = [string]::format("{0} days, {1} hours, {2} minutes, {3}.{4} seconds", `
        $runtime.Days, `
        $runtime.Hours, `
        $runtime.Minutes, `
        $runtime.Seconds, `
        $runtime.Milliseconds)
    $return_string
}