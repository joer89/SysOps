<#
  .Description
    Run the program and specify a group name in your Active Directory, this will populate a csv file with all the users inside.
  .Example
    .\GetAllGroupMembership.ps1
  .Notes
    Name  : GetAllGroupMembership
    Author: Joe Richards
  .Link
    https://github.com/joer89/Admin-Tools/
#>


#Imports the AD Module.
Import-Module activedirectory -ErrorAction Stop

function main{
    #Gets working directory
    [string]$dir = get-location
    #Stores file name.
    [string]$file
    #Creates the title.
    $titleWord = "Get all users from a group"
    $Title = (Get-Culture).TextInfo
    $Title.ToTitleCase($titleWord)

    #Stores the group name.
    $group = Read-Host "Which group would you like a list of?"
    #Stores the $group in $file.
    $file = $group

    #If group exists do the work else give use an error message.
    if (Get-ADGroup -Filter {SamAccountName -eq $group}){
            #exports all the items in the group.
            Get-ADGroupMember $group -Recursive | select name | Export-Csv $dir\$file.csv
        }
        else{
            #Writes out an error message.
            Write-Host "This Group does not exist $group."
        }
}

#Goes back to the menu.
do {
    Clear
    main
    $response= read-host "Press y for Main Menu?"
}
while ($response -eq "y")
