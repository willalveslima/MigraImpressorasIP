<#
.Synopsis
  Script Para Migração de endereços de IPs de impressoras em VLANs de Rede XXXX em Migração 

 .Description
  O Script lista as portas TCP/IP das impressoras instaladas na estação Windows 7, identifica os endereços que devem ser alterados.
  Exclui as instãncias de impressoras que terão os Endereço alterados e cria clones das impressoras com o endereço IP já migrado. 
  
  !!!!!!!!!!!!!
  !! Atenção !!
  !!!!!!!!!!!!!
  
  O Script está configurado para alterar somente o Terceiro octeto do endereço IP da Impressora, O FINAL DO ENDEREÇO IP SERÁ MANTIDO !
  Exemplo:
  
  192.168.240.222 -> 192.168.236.222 
  
  O ultimo octeto deve possuir 3 digitos (x.x.x.123)
     
  
 .Example
   .\MigraImpressorasIP.ps1
   
 .Link
  --------------

 .Notes
  v1.0 - 10/02/2016 
  

#>

#==============================================================================
# Script Name:    	MigraImpressorasIP.ps1
# DATE:           	10/02/2016
# Version:        	1.0
# COMMENT:			Migração de IP de impressoras - Projeto Endereçamento IP
# Author:           Willian Alves Lima 
#==============================================================================
#    

#Função para criação de uma nova Porta IP
Function PortInstall 
{             
    param ($PortName,$PrinterIP,$servername)             
               
    $PPrinter=([WMIClass]"\\.\ROOT\cimv2:Win32_TcpIpPrinterPort").CreateInstance()             
    $PPrinter.name           = $PortName             
    $PPrinter.Protocol       = 1             
    $PPrinter.HostAddress    = $PrinterIP             
    $PPrinter.PortNumber     = 9100             
    $PPrinter.Put()    
    $PPrinter=([WMIClass]"\\.\ROOT\cimv2:Win32_TcpIpPrinterPort")        
                 
}  

#função para a instalação de uma nova impressora     
    Function Printerinstall 
{             
    param ($caption,$PortName,$DriverName,$IsDefault=$false)              
                 
    $iprinter = ([WMIClass]"\\.\Root\cimv2:Win32_Printer").CreateInstance()             
    $iprinter.Caption     =$caption             
    $iprinter.DriverName  =$DriverName             
    $iprinter.PortName    =$PortName             
    $iprinter.DeviceID    =$caption             
    $iprinter.Default     = $IsDefault             
    $iprinter.Put()             
}
#Função para remoção de impressora 
function Remove-PrinterAndPort
{
    Param( $printername )
   $printer=gwmi win32_Printer -filter "name='$($printername)'"
   $printer.Delete()
   $port=gwmi win32_tcpipprinterport -filter "name='$($printer.portname)'" -enableall
   $port.Delete()
}

#início de processamento

#Recupera todas as portas TCP/IP de impressoras 
$portas = Get-WMIObject -Class Win32_tcpipPrinterport| Select Name,HostAddress

#Executa a verificação em cada uma das portas listadas
$portas | foreach {
       
    $nomePorta = $_.Name
    $endIP =  $_.HostAddress 
    
    $achou = $false
       
    #Site 01   
    if ($endIP.substring(0,10) -eq  "192.168.24.") {
        echo "Site 01 10 e 11 Andares"    
        $achou = $true 
        $novoIP = "192.168.241." + $endIP.substring(10,3)
    }
    elseif ($endIP.substring(0,10) -eq  "192.168.25.")
    {
        echo "Site 01 10 e 11 Andares"
        $achou = $true 
        $novoIP = "192.168.240." + $endIP.substring(10,3)
    }
    
    #Site 2
    elseif ($endIP.substring(0,10) -eq  "192.168.28.")
    {
        echo "Site 02  1 e 2 andares"
        $achou = $true 
        $novoIP = "192.168.24." + $endIP.substring(10,3)
    }
    
    #Site 3
    elseif ($endIP.substring(0,10) -eq  "192.168.170")
    {
        echo "Site 03  9 andar"
        $achou = $true 
        $novoIP = "192.168.230." + $endIP.substring(11,3)
    }
    
    #Site 4
    elseif ($endIP.substring(0,10) -eq  "192.168.223")
    {
        echo "Site 4  terreo e 1 andar"
        $achou = $true 
        $novoIP = "192.168.30." + $endIP.substring(11,3)

    }
    
    #Site 5
    elseif ($endIP.substring(0,10) -eq  "192.168.229")
    {
        echo "Site 5 2 Andar"     
        $achou = $true 
        $novoIP = "192.168.28." + $endIP.substring(11,3)
    }
    
    #Site 6
    elseif ($endIP.substring(0,10) -eq  "192.168.230")
    {
        echo "Sote 6  25 Andar"
        $achou = $true 
        $novoIP = "192.168.150." + $endIP.substring(11,3)
    }
    elseif ($endIP.substring(0,10) -eq  "192.168.231")
    {
        echo "Site 6 15 Andar"
        $achou = $true 
        $novoIP = "192.168.148." + $endIP.substring(11,3)
    }
    
    #Site 7
    elseif ($endIP.substring(0,10) -eq  "192.168.240")
    {
        echo "Site 7 10 e 11 Andares"
        $achou = $true 
        $novoIP = "192.168.236." + $endIP.substring(11,3)
    }
 
 <#teste   
  
    #SPO- Teste
    
    elseif ($endIP.substring(0,9) -eq  "192.168.4.")
    {
    write-host "TESTANDO ......"
        $achou = $true 
        $novoIP = "192.168.3." + $endIP.substring(9,3)
    }
 #>
 
 #caso exista impressoras a alterar:   
 
    if ($achou)
    {
        #Recupera os dados da impressora 
        $impressora = Get-WMIObject -Class Win32_Printer | Select Name,DriverName,PortName,Shared,ShareName,Default | where-object {$_.PortName -like $nomePorta}
        
         
        #remove a impressora
        #Remove-PrinterAndPort -printername $impressora.Name
 
        #cria uma nova impressora "clone" com IP migrado
        PortInstall -PortName $novoIP -PrinterIP $novoIP 
        Printerinstall -caption $impressora.Name -PortName $novoIP -IsDefault $impressora.Default -DriverName $impressora.DriverName
        
       
        # fim do IF 
        } 
 #fim do foreach
 }


       