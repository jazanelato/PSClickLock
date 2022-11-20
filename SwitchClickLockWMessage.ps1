Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$balmsg.BalloonTipTitle = "Click Lock"
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)

$MethodDefinition = @" 
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")] 
public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni); 
"@
$User32 = Add-Type -MemberDefinition $MethodDefinition -Name "User32Set" -Namespace Win32Functions -PassThru
$ClickLockQuery = Get-ItemPropertyValue -Path 'HKCU:\Control Panel\Desktop' -Name UserPreferencesMask
if ($ClickLockQuery[1] -eq 30)
{
    $ClickLockQuery[1] = 158
    $ClickLockState = 1
    $balmsg.BalloonTipText = 'Click Lock function has been enabled!'
}
else
{
    $ClickLockQuery[1] = 30
    $ClickLockState = 0
    $balmsg.BalloonTipText = 'Click Lock function has been disabled!'
}
$User32::SystemParametersInfo(0x101F,0,$ClickLockState,0) | Out-Null
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name UserPreferencesMask -Value $ClickLockQuery
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(5000)