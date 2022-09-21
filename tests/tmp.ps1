Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\DscTest'; SourcePath = 'D:\tmp'; Recurse = $true; Type = 'Directory'; Force = $true} -verbose -Method Get
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\DscTest'; SourcePath = 'D:\tmp'; Recurse = $true; Type = 'Directory'; Force = $true} -verbose -Method Test
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\DscTest'; SourcePath = 'D:\tmp'; Recurse = $true; Type = 'Directory'; Force = $true} -verbose -Method Set
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\DscTest'; SourcePath = 'D:\tmp'; Recurse = $true; Type = 'Directory'; Force = $true} -verbose -Method Test

Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{Ensure = 'Absent';DestinationPath = 'D:\DscTest'; SourcePath = 'D:\tmp'; Recurse = $true; Type = 'Directory'; Force = $true} -verbose -Method Set
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{Ensure = 'Absent';DestinationPath = 'D:\DscTest'; SourcePath = 'D:\tmp'; Recurse = $true; Type = 'Directory'; Force = $true} -verbose -Method Test
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{Ensure = 'Absent';DestinationPath = 'D:\DscTest'; SourcePath = 'D:\tmp'; Recurse = $true; Type = 'Directory'; Force = $true} -verbose -Method Get

Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\tmp\filet.txt'; Contents = 'bar'; Type = 'File'} -verbose -Method Get
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\tmp\filet.txt'; Contents = 'bar'; Type = 'File'} -verbose -Method Test
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\tmp\filet.txt'; Contents = 'bar'; Type = 'File'} -verbose -Method Set
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\tmp\filet.txt'; Contents = 'bar'; Type = 'File'} -verbose -Method Test
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{Ensure = 'Absent';DestinationPath = 'D:\tmp\filet.txt'; Contents = 'bar'; Type = 'File'} -verbose -Method Set
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{Ensure = 'Absent';DestinationPath = 'D:\tmp\filet.txt'; Contents = 'bar'; Type = 'File'} -verbose -Method Test

Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\tmp\filet.txt'; Contents = 'bar'; Type = 'File'} -verbose -Method Set
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\tmp\filet1.txt'; SourcePath = 'D:\tmp\filet.txt'; Type = 'File'} -verbose -Method Get
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\tmp\filet1.txt'; SourcePath = 'D:\tmp\filet.txt'; Type = 'File'} -verbose -Method Set
Invoke-DscResource -Name BetterFile -Module BetterFile -Property @{DestinationPath = 'D:\tmp\filet1.txt'; SourcePath = 'D:\tmp\filet.txt'; Type = 'File'} -verbose -Method Test
