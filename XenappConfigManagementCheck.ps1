

$ctxoutfile = "C:\tools\Powershell\xenappconfigmgmt.html"
$days = -7
$dayspositive = [math]::abs($days)
$citrixudl = "C:\tools\Powershell\xenappconfigmgmt.udl"
#do you want to be notified if a server is added - commonly happens if you xenappprep with pvs, change to yes if you do
$added = 'no'
Add-PSSnapin Citrix.Common.Commands
if ($added -eq 'yes')
{
Get-CtxConfigurationLogReport -datalinkpath $citrixudl -TimePeriodFrom (get-date ((get-date).AddDays($days)) -UFormat %m/%d/%y) -TimePeriodTo (get-date -UFormat %m/%d/%y)|Where-Object -Property Description -notlike "server*was installed"|ConvertTo-Html|out-file $ctxoutfile
}
else{
$h = Get-CtxConfigurationLogReport -datalinkpath $citrixudl -TimePeriodFrom (get-date ((get-date).AddDays($days)) -UFormat %m/%d/%y) -TimePeriodTo (get-date -UFormat %m/%d/%y)|ConvertTo-csv -NoTypeInformation|Convertfrom-csv
#remove server was installed due to PVS always reporting server additions after reboot
$H |Where-Object -Property description -notlike "Server*was installed*"|ConvertTo-Html|Out-File $ctxoutfile
}

$emailFrom     = "servername@domain.org"
$emailTo       = "group@domain.org"
$smtpServer    = "mail.domain.org"
$emailSubject  = ("Xenapp Farm Config Management Changes " + (Get-Date -format R) )

$mailMessageParameters = @{
	From       = $emailFrom
	To         = $emailTo
	Subject    = $emailSubject
	SmtpServer = $smtpServer
	Body       = "Xenapp Configuration Changes made in the last " + $dayspositive + " days `n" + (gc $ctxoutfile)| Out-String
	Attachment = $ctxoutfile
}

Send-MailMessage @mailMessageParameters -BodyAsHtml