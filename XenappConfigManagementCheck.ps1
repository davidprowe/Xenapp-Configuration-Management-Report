

$ctxoutfile = "C:\tools\Powershell\xenappconfigmgmt.html"
$days = -7
$dayspositive = [math]::abs($days)
$citrixudl = "C:\tools\Powershell\xenappconfigmgmt.udl"
Add-PSSnapin Citrix.Common.Commands
Get-CtxConfigurationLogReport -datalinkpath $citrixudl -TimePeriodFrom (get-date ((get-date).AddDays($days)) -UFormat %m/%d/%y) -TimePeriodTo (get-date -UFormat %m/%d/%y)|ConvertTo-Html|out-file $ctxoutfile

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