function New-MarkovChainText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$InputTextPath = 'trump.txt',
        [Parameter(Mandatory = $false)]
        [int]$PrefixSize = 2,
        [Parameter(Mandatory = $false)]
        [int]$FinalLength = 8
    )

    # TODO: Get around statically defining end symbol
    # TODO: Include $PrefixSize to solution
    # TODO: Include $FinalLength to solution
    # TODO: Add function to check whether sentences in generated output exist
    #       in input text

    $EndSymbol = 'END'
    $InputText = Get-Content -Path $InputTextPath
    $InputText += $EndSymbol
    $InputWords = $InputText.Split(' ')
    $Phrases = New-Object System.Collections.Specialized.OrderedDictionary

    for ($Index = 0; $Index -lt $InputWords.Length; $Index++) {
        $Prefix = "$($InputWords[$Index]) $($InputWords[$Index + 1])"
        $Suffixes = Find-Suffixes -InputText $InputText -Prefix $Prefix

        if ($Prefix -cmatch $EndSymbol) {
            $Prefix = $Prefix.Replace($EndSymbol, '')
            $Suffixes = 'END'
            $Phrases = Add-PhraseToList -OrderedList $Phrases -Prefix $Prefix -Suffixes $Suffixes
            break
        }

        $Phrases = Add-PhraseToList -OrderedList $Phrases -Prefix $Prefix -Suffixes $Suffixes
    }

    # $Phrases
    $Text = Get-Phrase -Phrases $Phrases
    $Text -join ' '
}

function Find-Suffixes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$InputText,
        [Parameter(Mandatory = $false)]
        [string]$Prefix
    )

    # NOTE: Kind of breaks down when there are brackets within the suffix
    return [Regex]::Matches($InputText, "(?<=$Prefix\s)\w*\.?").Groups.Value
}

function Get-RandomSuffix {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [object]$Phrase
    )

    # TODO: Replace passing entire phrase to just the suffix itself
    $Suffix = $Phrase.Value

    if ($Suffix.Count -ne 1) {
        $Suffix = $Phrase.Value | Get-Random -Count 1
    }

    return [string]$Suffix
}

function Add-PhraseToList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [object]$OrderedList,
        [Parameter(Mandatory = $false)]
        [string]$Prefix,
        [Parameter(Mandatory = $false)]
        [array]$Suffixes
    )

    if ($OrderedList.Keys -notcontains $Prefix) {
        $OrderedList.Add($Prefix, $Suffixes)
    }

    return $OrderedList
}



# function Get-Phrase {
#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory = $false)]
#         [object]$Phrases,
#         [Parameter(Mandatory = $false)]
#         [int]$Length
#     )


#     # https://stackoverflow.com/a/33156229
#     $FinalText = New-Object System.Collections.Generic.List[System.Object]
#     [array]$Prefixes = $Phrases.Keys

#     foreach ($Prefix in $Prefixes) {
#         $Phrase = $Phrases.GetEnumerator() |
#             Where-Object { $_.Name -eq $Prefix }

#         $Suffix = Get-RandomSuffix -Phrase $Phrase
#         $FinalText.Add($Prefix)
#         $FinalText.Add($Suffix)

#         if (($Suffix -match '\.$') -or ($Suffix -eq '(end)')) {
#             break
#         }
#     }

#     return $FinalText
# }

function Get-Phrase {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [object]$Phrases
    )

    # https://stackoverflow.com/a/33156229
    $FinalText = New-Object System.Collections.Generic.List[System.Object]
    [array]$Prefixes = $Phrases.Keys
    $Index = 0

    do {
        $Prefix = $Prefixes[$Index]

        # If suffix exists from previous iteration
        if ($null -ne $Suffix) {
            $Prefix = $Prefixes |
                Where-Object { ($_ -match "$Suffix\.?$") -and (
                    [array]::IndexOf($Prefixes, $_) -gt $Index) } |
                Get-Random -Count 1

            if ($null -eq $Prefix) {
                break
            }
        }

        $Phrase = $Phrases.GetEnumerator() |
            Where-Object { $_.Name -eq $Prefix }

        $Suffix = Get-RandomSuffix -Phrase $Phrase

        $FinalText.Add($Prefix)
        $FinalText.Add($Suffix)

        if (($Suffix -eq '(end)')) {
            break
        }

        $Index = [array]::IndexOf($Prefixes, $Prefix)
    } while ($Index -le $Prefixes.Length)

    return $FinalText
}

New-MarkovChainText -Verbose
