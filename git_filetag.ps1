function Set-FileTag {# store $FileTags as JSON in Git Notes
    git notes add -f -m ($FileTags | ConvertTo-Json -Compress).replace('"',"'")
}

function Update-FileTag {
    [array]$Properties = @(# Categories to use
        'BaseName',
        'Extension',
        'Name',
        'DisplayName',  # Original filename
        'TechField',    # Field of technolgy the files is about
        'DocType',      # What the file is used for, i.e. Reports, Manual, Request etc.
        'Owner'         # Person repsonsible for the content of the document
    )

    [array]$Ignore = @(# file types to omit
        '.vscode',
        '.git'
    )
<# TODO Remove very soon
    $Global:FileTags = Get-ChildItem -File | where {$Ignore -notcontains $_.Extension} | # filter out extensions
    select $Properties | 
    foreach { 
        if ($_.BaseName -notmatch '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}') {# don't touch added files (GUID) 
            $_.DisplayName = $_.Name; # keep original filename
            $_.BaseName = (New-Guid).ToString(); 
            Rename-Item $_.Name ($_.BaseName + $_.Extension) # make filename unique
            $_.Name = ($_.BaseName + $_.Extension)
        }; 
        $_
    }
 #>    

    $global:FileTags = Get-FileTag
    
    #Handel new files
    Get-ChildItem -Exclude $FileTags.Name |
    where {$Ignore -notcontains $_.Extension} | # filter out extensions
    select $Properties |
    foreach {
        $_.DisplayName = $_.Name; # keep original filename
        $_.BaseName = (New-Guid).ToString()
        #Rename-Item $_.Name ($_.BaseName + $_.Extension) # make filename unique
        $_.Name = ($_.BaseName + $_.Extension)
        $Global:FileTags += $_
    }

    # Build thick index tabels
    $Global:GuidTable = @{}
    $Global:NameTable = @{}
    $FileTags | foreach {
        $Global:GuidTable.add($_.Name,$_)
        try {$Global:NameTable.add($_.DisplayName,$_)}
        catch {Write-Error -Message 'Name table creation failed'}
    }

    Set-FileTag
}

function Get-FileTag {# get file tags from Git Notes
    git log --format="%H`t%s`t%ai`t%N" -n 1 | 
    ConvertFrom-Csv -Delimiter "`t" -Header ('CommitId','Message','Date','Note') | 
    select -ExpandProperty Note | ConvertFrom-Json
}

<#
.SYNOPSIS
    Creates a PS Custom object based on the files in the current directory and add 
    fields for tagging the files.

    The tags can be used for filtering and grouping the directory content.
    
.DESCRIPTION
    Long description

.EXAMPLE
    PS C:\> Update-FileTag

    Creates the variable $FileTags and popultaes it with the  file names 
    of the current folder.
    
    Then replaces all file names with GUID:s to be able to track the files.

.EXAMPLE
    PS C:\> Set-FileTag

    Stores the content and structure of $FileTags as JSON compressed in 
    Git Notes.

.EXAMPLE
    PS C:\> Get-FileTag

    Reads the JSON from Git Notes and replaces/creates the global variable 
    $FileTags

.EXAMPLE
    PS C:\> $FileTags | format-table

    BaseName                             Extension Name           DisplayName    TechField DocType Owner
    --------                             --------- ----           -----------    --------- ------- -----
    9eac68c0-53ca-4213-bf4f-cf84af7749eb .vscode   .vscode        .vscode
    68113f0e-7536-46a9-90cd-0edc90bf057d .md       anotherfile.md anotherfile.md
    aa7e427d-2390-4258-afd8-2ec92e051b26 .md       readme.md      readme.md
    112c2b2b-904a-49b1-8d78-e772a0048bfe .md       thatfile.md    thatfile.md
    bbc9138e-0735-4231-82d1-c393ceb81905 .md       thisfile.md    thisfile.md

    Displays all metainformation about the files in the current directory

.EXAMPLE
    $FileTags[0].Owner = $ENV:USERNAME

    Set the owner of the first record of the $FileTags variable.

.EXAMPLE
    $FileTags | where Owner -eq $ENV:USERNAME

    Show all the files owned by the current user.

.EXAMPLE
    $FileTags[1].TechField = 'MSSQL'
    $FileTags[3].TechField = 'SharePoint'
    $FileTags[4].TechField = 'SharePoint','PowerShell'

    Set the TechField category for record 1,3 and 4

.EXAMPLE
    $FileTags[1].DocType = 'MonthlyReport'
    $FileTags[2].DocType = 'Documentation'
    $FileTags[3].DocType = 'MonthlyReport'

    Set the DocType category for record 1,2 and 3

.EXAMPLE
    $FileTags | where DocType -eq 'MonthlyReport'

    Get all MontlyReports

.EXAMPLE
    $FileTags | where TechField | ft -GroupBy TechField

    Get all records that has a TechField and Group the output.

.NOTES
    General notes
#>