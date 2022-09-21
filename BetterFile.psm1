
enum ensure
{
    present
    absent
}

enum objectType
{
    file
    directory
    symboliclink
}
enum linkBehavior
{
    follow
    manage
}
enum checksumType
{
    md5
    mtime
    ctime
}

enum encoding
{
    ASCII
    Latin1
    UTF7
    UTF8
    UTF32
    BigEndianUnicode
    Default
    Unicode
}

[DscResource()]
class BetterFile
{
    [DscProperty(Key)]
    [string]
    $DestinationPath

    [DscProperty()]
    [string]
    $SourcePath

    [DscProperty()]
    [ensure]
    $Ensure = [ensure]::present

    [DscProperty()]
    [objectType]
    $Type = [objectType]::directory

    [DscProperty()]
    [string]
    $Contents

    [DscProperty()]
    [checksumType]
    $Checksum = [checksumType]::md5

    [DscProperty()]
    [bool]
    $Recurse = $false

    [DscProperty()]
    [bool]
    $Force = $false

    [DscProperty()]
    [linkBehavior]
    $Links = [linkBehavior]::follow

    [DscProperty()]
    [string]
    $Group

    [DscProperty()]
    [string]
    $Mode

    [DscProperty()]
    [string]
    $Owner

    [DscProperty(NotConfigurable)]
    [datetime]
    $CreatedDate

    [DscProperty(NotConfigurable)]
    [datetime]
    $ModifiedDate

    [DscProperty()]
    [encoding]
    $Encoding = 'Default'

    [DscProperty()]
    [bool]
    $IgnoreTrailingWhitespace

    [BetterFile] Get ()
    {
        $returnable = @{
            DestinationPath          = ''
            SourcePath               = $this.SourcePath
            Ensure                   = $this.Ensure
            Type                     = $this.Type
            Contents                 = ''
            Checksum                 = $this.Checksum
            Recurse                  = $this.Recurse
            Force                    = $this.Force
            Links                    = $this.Links
            Encoding                 = $this.Encoding
            Group                    = ''
            Mode                     = ''
            Owner                    = ''
            IgnoreTrailingWhitespace = $this.IgnoreTrailingWhitespace
            CreatedDate              = [datetime]::new(0)
            ModifiedDate             = [datetime]::new(0)
        }

        $object = Get-Item -ErrorAction SilentlyContinue -Path $this.DestinationPath -Force
        if (-not $object)
        {
            return $returnable
        }

        if (($object.Attributes -band 'ReparsePoint') -eq 'ReparsePoint')
        {
            $returnable.Type = 'SymbolicLink'
        }
        elseif (($object.Attributes -band 'Directory') -eq 'Directory')
        {
            $returnable.Type = 'Directory'
        }
        else
        {
            $returnable.Type = 'File'
        }

        $returnable.DestinationPath = $object.FullName    
        if ($object -and $this.Type -eq [objectType]::file)          
        {
            $returnable.Contents = Get-Content -Raw -Path $object.FullName -Encoding $this.Encoding.ToString()
        }

        if (-not $this.Ensure -eq 'Absent' -and -not [string]::IsNullOrWhiteSpace($returnable.Contents) -and $this.IgnoreTrailingWhitespace)
        {
            $returnable.Contents = $returnable.Contents.Trim()
        }

        $returnable.CreatedDate = $object.CreationTime
        $returnable.ModifiedDate = $object.LastWriteTime
        $returnable.Owner = $object.User
        $returnable.Mode = $object.Mode
        $returnable.Group = $object.Group
              
        return $returnable
    }

    [void] Set()
    {
        if ($this.Ensure -eq 'Absent')
        {
            Remove-Item -Recurse -Force -Path $this.DestinationPath
            return
        }
        if (-not $this.Recurse -and $this.Type -eq 'Directory')
        {
            $null = New-Item -ItemType Directory -Path $this.DestinationPath
        }

        if ($this.Type -eq 'SymbolicLink')
        {
            New-Item -ItemType SymbolicLink -Path $this.DestinationPath -Value $this.SourcePath
            return
        }

        if ($this.Contents)
        {
            $this.Contents | Set-Content -Path $this.DestinationPath -Force -Encoding $this.Encoding.ToString() -NoNewline
        }

        if ($this.SourcePath)
        {
            $tmpPath = $this.SourcePath
            if ($this.Type -eq 'Directory')
            {
                $tmpPath = Join-Path -Path $tmpPath -ChildPath '*'
            }
            Write-Verbose "Copying from $tmpPath to $($This.DestinationPath), Recurse is $($this.Recurse), Using the Force: $($this.Force)"
            Copy-Item -Path $tmpPath -Destination $this.DestinationPath -Recurse:$this.Recurse -Force:$this.Force
        }
    }

    [bool] Test()
    {
        $currentState = $this.Get()

        if ($this.Ensure -eq 'Absent' -and -not $currentState.DestinationPath)
        {
            return $true
        }

        if (-not $currentState.DestinationPath)
        {
            Write-Verbose -Message 'Destination Path empty'
            return $false
        }

        if ($this.Contents -and $this.Contents -ne $currentState.Contents)
        {
            Write-Verbose -Message "File content different $($this.Contents) <> $($currentState.Contents)"
            return $false
        }

        if ($this.Type -ne $currentState.Type)
        {
            Write-Verbose -Message "Type $($currentState.Type) <> $($this.Type)"
            return $false
        }

        if ($this.SourcePath)
        {
            $currHash = BetterFile\Compare-Hash -Path $this.DestinationPath -ReferencePath $this.SourcePath -Type $this.Checksum -Recurse:$this.Recurse

            if ($currHash.Count -gt 0)
            {
                Write-Verbose -Message "Hashes were wrong"
                return $false
            }
        }

        return $true
    }
}
function Compare-Hash
{
    [OutputType([System.IO.FileInfo])]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [string]
        $ReferencePath,

        [Parameter()]
        [checksumType]
        $Type = 'md5',

        [Parameter()]
        [switch]
        $Recurse
    )

    [object[]]$sourceHashes = BetterFile\Get-Hash -Path $ReferencePath -Recurse:$Recurse -Type $Type
    [object[]]$hashes = BetterFile\Get-Hash -Path $Path -Type $Type -Recurse:$Recurse

    if ($hashes.Count -eq 0) { return [System.IO.FileInfo[]]$sourceHashes.Path }

    foreach ($hash in $sourceHashes)
    {
        # Path is in list, compare hashes
        $hashedThing = $hashes | Where-Object {
            $_.Path.Replace($Path, $ReferencePath) -eq $hash.Path
        }

        if ($hashes.Count -eq 1 -and $null -eq $hashedThing)
        {
            $hashedThing = $hash.Where( { $_.Path -eq $ReferencePath })
        }
        if ($hashedThing.Hash -ne $hash.Hash) { [System.IO.FileInfo]$hash.Path }
    }
}

function Get-Hash
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter()]
        [checksumType]
        $Type,

        [Parameter()]
        [switch]
        $Recurse
    )

    if ($Type -eq 'md5')
    {
        Get-ChildItem -Recurse:$Recurse.IsPresent -Path $Path -Force -File | Get-FileHash -Algorithm md5
    }
    else
    {
        $propz = @(
            @{Name = 'Path'; Expression = { $_.FullName } }
            @{Name = 'Algorithm'; Expression = { $Type } }
            @{Name = 'Hash'; Expression = { if ($Type -eq 'ctime') { $_.CreationTime } else { $_.LastWriteTime } } }
        )
        Get-ChildItem -Recurse:$Recurse.IsPresent -Path $Path -Force -File | Select-Object -Property $propz
    }
}
