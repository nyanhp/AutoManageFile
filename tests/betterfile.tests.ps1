BeforeDiscovery {
    Import-Module $PSScriptRoot/../BetterFile.psd1 
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
}
Describe 'BetterFile Module' {
    Context 'Compare-Hash function' {
        function Get-Hash {}
        $dest = '/destinationPath'
        $destFiles = 1..10 | % { [pscustomobject]@{Path = Join-Path $dest $_; Hash = $_; Algorithm = 'md5' } }
        $casesGood = @(
            @{
                SourcePath       = '/sourcePath'
                SourceFiles      = 1..10 | % { [pscustomobject]@{Path = "/sourcePath/$_"; Hash = $_; Algorithm = 'md5' } }
                DestinationPath  = $dest
                DestinationFiles = $destFiles
            }
        )
        $casesBad = @(
            @{
                SourcePath       = '/sourcePathBad'
                SourceFiles      = 1..5 | % { [pscustomobject]@{Path = "/sourcePathBad/$_"; Hash = $_ ; Algorithm = 'md5' } }
                DestinationPath  = $dest
                DestinationFiles = $destFiles
            }
        )

        It 'Returns empty collection when hashes are equal' -TestCases $casesGood {
            Mock -CommandName BetterFile\Get-Hash -MockWith {
                $casesGood.SourceFiles
            } -ParameterFilter { $Path -eq $casesGood.SourcePath }
            Mock -CommandName BetterFile\Get-Hash -MockWith {
                $destFiles
            } -ParameterFilter { $Path -eq $dest }
            (Compare-Hash -Path $DestinationPath -ReferencePath $SourcePath -Type md5).Count | Should -Be 0
        }
        It 'Returns non-empty collection if hashes do not match' -TestCases $casesBad {
            Mock -CommandName BetterFile\Get-Hash -MockWith {
                $casesBad.SourceFiles
            } -ParameterFilter { $Path -eq $casesBad.SourcePath }
            Mock -CommandName BetterFile\Get-Hash -MockWith {
                $destFiles
            } -ParameterFilter { $Path -eq $dest }
            (Compare-Hash -Path $DestinationPath -ReferencePath $SourcePath -Type md5).Count | Should -BeExactly $($DestinationFiles.Count - $SourceFiles.Count)
        }
    }
    Context 'Invoke DSC Get' -Skip {
        It 'Returns a BetterFile type' {
            #Invoke-DSCResource -Name BetterFile -ModuleName BetterFile -Method Get -Property @{Exclude = 'mySampleAccount'} | Should -BeOfType 'BetterFile'
        }
        It 'Has correct properties' {
            Invoke-DSCResource -Name BetterFile -ModuleName BetterFile -Method Get -Property @{Exclude = 'mySampleAccount' } | gm -MemberType Properties | % Name | Should -Be @('CompliantUsers', 'Exclude', 'NonCompliantUsers', 'Reasons')
        }
        It 'Execution with empty parameter' {
            Invoke-DSCResource -Name BetterFile -ModuleName BetterFile -Method Get -Property @{Exclude = '' } | % Exclude | Should -BeNullOrEmpty
        }
        It 'Returns a Reasons code' {
            Invoke-DSCResource -Name BetterFile -ModuleName BetterFile -Method Get -Property @{Exclude = 'mySampleAccount' }  | % Reasons | % Code | Should -Be 'BetterFile:BetterFile:Accounts'
        }
    }
    Context 'Invoke DSC Test' -Skip {
        It 'Execution with empty parameter' {
            Invoke-DSCResource -Name BetterFile -ModuleName BetterFile -Method Test -Property @{Exclude = '' } | % Exclude | Should -BeNullOrEmpty
        }
        It 'Execution with parameter' {
            Invoke-DSCResource -Name BetterFile -ModuleName BetterFile -Method Test -Property @{Exclude = 'mySampleAccount' } | % InDesiredState | Should -BeOfType Boolean
        }
    }
}