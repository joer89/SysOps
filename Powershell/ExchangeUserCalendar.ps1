<#
  .Description
      You can install the Exchange System Management Tools on your local machine or you will have to run this on the Exchange server in the Exchange Console.
      This script gives a user permission to access someone elses calendar and and view a users calendar.
  .Example
    .\Source Code.ps1
  .Notes
      Name  : ExchangeUserCalendar
      Author: Joe Richards
      Date  : 26/03/2015
  .Link
    https://github.com/joer89/Admin-Tools/
#>

#Try to imports the Active directory module and stops the program if it does not exist.
try{
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "AD module has been loaded."
}
catch{
    Write-Host "Can not import the AD module." -foregroundcolor red 
}

#Prerequisites for setting the mailbox permissions.
function prepSetMailBx{
    #The link has access rights parameters.
    Write-Host -ForegroundColor Red "For Access Rights' options visit: `nhttps://technet.microsoft.com/en-GB/library/dd298062(v=exchg.150).aspx"
    #Stores the domain name.
    $domain = (Get-ADDomain).Name + "\"
    #Stores the owners username.
    $usrOwner = Read-Host "Enter the owner's username: "
    #Stores the requesters username.
    $usrRequester = Read-Host "Enter the requester's username: "
    #Stores the access level.
    $access = Read-host "Enter the access rights: "            
    #Reformats the username in the format of domain\username:\calendar and puts it in $owner.
    $owner = $domain + $usrOwner + ":\calendar"
    #Reformats the requesters username in the format of domain\username.
    $requester = $domain + $usrRequester 
    #Gives the function the parameters.
    Set-MailBxPermissions -ownerUsr $owner -guestUsr $requester -accessRights $access
}
#End FUnction

#Prerequisites forretriving the mailbox permissions.
function prepGetMailBx{
    #Stores the domain name.
    $domain = (Get-ADDomain).Name + "\"
    #Stores the owners username.
    $usrOwner = Read-Host "Enter the owner's username: "
    #Reformats the username in the format of domain\username:\calendar and puts it in $user.
    $user = $domain + $usrOwner + ":\calendar"  
    #Gives the function the paramter.
    Get-MailBxPermissions -ownerUsr $user
}
#End Function

#Gives access to a users calendar
function Set-MailBxPermissions{
    #ownerUsr is the owners username in the format of domain\username:\calendar
    #guestUsr is the requesters username.
    #accessRights is the access which is required for the calendar.
    param ([String]$ownerUsr,[String]$guestUsr,[String]$accessRights)
    #Displays the key details of whats about to be set.
    Write-Host "`n `tOwner's username: "  $ownerUsr "`n `tRequester's username: " $guestUsr "`n `tAccess right: " $accessRights
    try{
        #Sets the calendar permissions.
        Add-MailboxFolderPermission -Identity $ownerUsr -User $guestUsr -AccessRights $accessRights
    }
    catch{
        #Displays a simple error.
        Write-Error "Failed to set owners calendar."
    }
    Finally{
        #Goes back to the menu.
        MenuOptions
    }
}
#End function

#Reads the mailbox permissions of a user specified.
function Get-MailBxPermissions{
    #ownerUsr is the owners username in the format of domain\username:\calendar
    param ([String]$ownerUsr)
    
    #Displays the owners username in the format of domain\username:\calendar
    Write-Host "`n `tOwner's username: "  $ownerUsr   
    try{
        #Retrives the users mailbox folder permissions. 
        Get-MailboxFolderPermission -identity $ownerUsr
    }
    catch{
        #Displays a simple error.
        Write-Error "Failed to view owners calendar."
    }
    Finally{
        #Goes back to the menu.
        MenuOptions
    }
}
#End Function

function menuOptions{
    #the storage of the menu's user choice 
    [int]$choice = 0

    while($choice -lt 1 -or $choice -gt 3){
        #Display the options in the menu.
        Write-Host "1. Set a user mailbox permissions."
        Write-Host "2. Get a user mailbox permissions."
        Write-Host "3. Quit"
    
        #Stores the users menu option.
        $choice  = Read-Host "Please choose an option"
        
        Switch ($choice) {
            1{prepSetMailBx}
            2{prepGetMailBx}
            3{#Exits the script.
              Exit}
            default{
                #goes to the menu.
                menuOptions
            }
        }
    }
}

MenuOptions