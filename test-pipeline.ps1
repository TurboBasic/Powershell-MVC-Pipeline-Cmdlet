# Helps to get detailed structure of pipelined data inside cmdlet
# Fully implements MVC

Function model__New-Content ($__computerName, $__PSBoundParameters) {
  @{
    content = @{
        computerType = $( try   { $__computerName.GetType() } 
                          catch { $null }
                        );
        computerName = $($__computerName | Out-String).trimEnd("`n");
        callParameters = $(
            $__PSBoundParameters | Format-Table -AutoSize | Out-String
        )
    }
  }
}


Function view__Get-Style ( $level ) {
  $Styles = @{
    levelBegin = @{
      margin = " " * 0
      color =  "Gray"
    }
    levelProcess = @{
      margin = " " * 4
      color =  "White"
    }
    levelProcessEach = @{
      margin = " " * 12
      color =  "Yellow"
    }
    levelEnd = @{
      margin = " " * 0
      color =  "Green"
    }
  }

  @{ 
    style = $Styles[$level]
  }
}


Function view__Get-ContentTemplate ( $level ) {

  $Template = @'
{0}{{header}}
{0}   {{item}} is a {1} with value {2}   
{0}   $PSBoundParameters is {3}
'@

  $Placeholders = @{
    header = @{
      levelBegin =       "BEGIN Block -"
      levelProcess =     "PROCESS Block -"
      levelProcessEach = "PROCESS Block, FOREACH LOOP -"
      levelEnd =         "END Block - "
    }
    
    item = @{
      levelBegin =       '$ComputerName'
      levelProcess =     '$ComputerName'
      levelProcessEach = 'processed item'
      levelEnd =         '$ComputerName'
    }
  }


  $Template | ForEach-Object {
    [Regex]::Replace($_, '{{(\p{L}+)}}', {
      param($Match)
      return $Placeholders[$Match.Groups[1].Value][$level]
    })
  } | ForEach-Object { @{ template = $_ } }

}


Function view__Display-Text($style, $template, $content) {
  $callParametersStyled = $content.callParameters -split "`n" |
    ForEach-Object { $style.margin + (" "*6) + $_ } |
    Out-String

  $text = $template -f $style.margin, $content.computerType, $content.computerName, $callParametersStyled

  Write-Host $text -foregroundColor $style.color
}


Function controller__Print-Message($level, $content) {

  $viewParams  = @{}
  $viewParams += $content
  $viewParams += view__Get-ContentTemplate $level
  $viewParams += view__Get-Style $level 

  view__Display-Text @viewParams

}


Function Test-Pipeline {
<#
    .SYNOPSIS
        Processes pipeline or direct input and prints objects inside the Pipeline

    .DESCRIPTION
        Processes pipeline or direct input and provide detailed messages about internal state of Powershell command pipeline

    .PARAMETER ComputerName
        Demo parameter. Accepts both multiple items both directly and from pipeline

    .NOTES
        Name:    Test-Pipeline
        Author:  Andriy Melnyk
        Created: 16 Jun 2017

        Based on excellent code of @RamblingCookieMonster from https://ramblingcookiemonster.wordpress.com/2014/12/29/powershell-pipeline-demo/

    .EXAMPLE
        PS> Test-Pipeline "Item1" PC2 Server3

BEGIN Block -
   $ComputerName is a System.String[] with value Item1,PC2,Server3   
   $PSBoundParameters is       
      Key          Value                
      ---          -----                
      ComputerName {Item1, PC2, Server3}
      
    PROCESS Block -
       $ComputerName is a System.String[] with value Item1,PC2,Server3   
       $PSBoundParameters is           
          Key          Value                
          ---          -----                
          ComputerName {Item1, PC2, Server3}

            PROCESS Block, FOREACH LOOP -
               processed item is a System.String with value Item1   
               $PSBoundParameters is                   
                  Key          Value                
                  ---          -----                
                  ComputerName {Item1, PC2, Server3}

            PROCESS Block, FOREACH LOOP -
               processed item is a System.String with value PC2   
               $PSBoundParameters is                   
                  Key          Value                
                  ---          -----                
                  ComputerName {Item1, PC2, Server3}

            PROCESS Block, FOREACH LOOP -
               processed item is a System.String with value Server3   
               $PSBoundParameters is                   
                  Key          Value                
                  ---          -----                
                  ComputerName {Item1, PC2, Server3}

END Block - 
   $ComputerName is a System.String[] with value Item1,PC2,Server3   
   $PSBoundParameters is       
      Key          Value                
      ---          -----                
      ComputerName {Item1, PC2, Server3}

        Description
        -----------
        Iterates through directly entered items and prints internal state of pipeline at various stages of lifecycle


    .EXAMPLE
        PS> "Item1", "PC2", "Server3" | p
BEGIN Block -
   $ComputerName is a System.String[] with value BBRO   
   $PSBoundParameters is       

    PROCESS Block -
       $ComputerName is a System.String[] with value Item1   
       $PSBoundParameters is           
          Key          Value  
          ---          -----  
          ComputerName {Item1}

            PROCESS Block, FOREACH LOOP -
               processed item is a System.String with value Item1   
               $PSBoundParameters is                   
                  Key          Value  
                  ---          -----  
                  ComputerName {Item1}

    PROCESS Block -
       $ComputerName is a System.String[] with value PC2   
       $PSBoundParameters is           
          Key          Value
          ---          -----
          ComputerName {PC2}

            PROCESS Block, FOREACH LOOP -
               processed item is a System.String with value PC2   
               $PSBoundParameters is                   
                  Key          Value
                  ---          -----
                  ComputerName {PC2}

    PROCESS Block -
       $ComputerName is a System.String[] with value Server3   
       $PSBoundParameters is           
          Key          Value    
          ---          -----    
          ComputerName {Server3}

            PROCESS Block, FOREACH LOOP -
               processed item is a System.String with value Server3   
               $PSBoundParameters is                   
                  Key          Value    
                  ---          -----    
                  ComputerName {Server3}

END Block - 
   $ComputerName is a System.String[] with value Server3   
   $PSBoundParameters is       
      Key          Value    
      ---          -----    
      ComputerName {Server3}


        Description
        -----------
        Iterates through arguments supplied from pipeline and prints internal state of pipeline at various stages of lifecycle
#>

  #region Parameters
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]            
    param(            
        [parameter( Mandatory = $false,            
                    ValueFromPipeline = $True,            
                    ValueFromPipelineByPropertyName = $True)]            
        [string[]]$ComputerName = "$env:computername",            
            
        [switch]$Force            
    ) 
  #endregion
  
            
  Begin {            
    $RejectAll = $false            
    $ConfirmAll = $false
    
    $ComputerName | Out-String -Stream | Write-Verbose

    $model__initialContent = model__New-Content $ComputerName $PSBoundParameters
    controller__Print-Message -Level "levelBegin" -Content $model__initialContent
  }

            
  Process {
    #region ConfirmationQuestions
      Function ShouldIExecuteAction ($target) {
        $query = "Are you REALLY sure you want to process ${target}?"
        $caption = "Processing ${target}"

        return ($Force -Or $PSCmdlet.ShouldContinue($query, $caption, [ref]$ConfirmAll, [ref]$RejectAll))
      }

      Function ShouldIProcessItem ($target) {
        $verboseDescription = "Processed the computer ${target}"
        $verboseWarningQuestion = "Process the computer ${target}?" 
        $caption = "Processing computer"
        return $PSCmdlet.ShouldProcess( $verboseDescription, $verboseWarningQuestion, $caption )
      }
    #endregion

    $ComputerName | Out-String -Stream | Write-Verbose

    $model__loopContent = model__New-Content $ComputerName $PSBoundParameters
    controller__Print-Message -Level "levelProcess" -Content $model__loopContent    
                
    foreach($Computer in $ComputerName) {
      $model__singleItemContent = model__New-Content $Computer $PSBoundParameters

      if( ShouldIProcessItem $model__singleItemContent.content.computerName ) {
        if( ShouldIExecuteAction($model__singleItemContent.content.computerName) ) {  
          controller__Print-Message -Level "levelProcessEach" -Content $model__singleItemContent
        }            
      }            
    }            
  }

            
  End {
    $model__endContent = model__New-Content $ComputerName $PSBoundParameters
    controller__Print-Message -Level "levelEnd" $model__endContent         
  }            
}

New-Alias p Test-Pipeline -Force