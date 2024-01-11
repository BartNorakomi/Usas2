#Put one or more file(s) in the archive and date it
#files gets copied to .\versions\<filename>.date.<ext>
#20230719;romvdmeulen;new 

[CmdletBinding()]
Param
(	[Parameter(Mandatory=$true)][string]$filename,	#may contain wildcarts
	[switch]$apply
)


# Functions
function execute-cmd
{	Param
	(	$cmd
	)
	if (!$script:apply) {write-verbose "PS> $cmd";} else {invoke-expression ($cmd);}
}

# Main:
$container="versions"
if (-not (test-path $container)) {execute-cmd -cmd "new-item -Name $container -ItemType Directory"} 

foreach ($file in (get-item $filename))
{	$newFileName=$file.basename+"."+(get-date -format yyyyMMdd)+$file.extension
	write-verbose "renaming to: $newFileName"
	execute-cmd -cmd "copy-item $file -destination '.\$container\$newFilename'"
}

