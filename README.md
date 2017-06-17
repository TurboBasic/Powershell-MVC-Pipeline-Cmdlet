# Powershell-MVC-Pipeline-Cmdlet
Template of Windows Powershell Cmdlet based on MVC pattern. Allow to look into the details of what's going on inside Powershell command pipeline

<img src="https://raw.githubusercontent.com/TurboBasic/dotfiles.windows/master/hexagram.png" alt="Windows Dotfiles" style="width: 100px; height: auto;" />

````
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
````
