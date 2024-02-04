
$departments = @("HR","Sales","Consultants","IT","Finance")
foreach ($department in $departments) {
    $departmentUsers = Get-ADUser -Filter "Department -eq '$department'" -Properties Department | 
                        Select-Object samAccountName, Name, Department
    
    foreach ($user in $departmentUsers) {
        Add-ADGroupMember -Identity "g_$department" -Members $user.samAccountName
    }


}#>

$departments = @("HR","Sales","Consultants","IT","Finance")
foreach ($department in $departments) {
    $departmentUsers = Get-ADUser -Filter "Department -eq '$department'" -Properties Department | 
                        Select-Object samAccountName, Name, Department
    
    foreach ($user in $departmentUsers) {
        Add-ADGroupMember -Identity "g_$department" -Members $user.samAccountName
    }


}

<#FileShareHR_Read (and all other departments)
FileShareHR_Write (and all other departments)
FileShareAll_Write
FileShareAll_Read
Printers_ManageAccess
Printers_access
FrontDoor_Access#>


# Edit this variables to match your environment
$OU = "InfraIT_Groups"
 
# Retrieve the OU's distinguished name
$ouPath = Get-ADOrganizationalUnit -Filter * | where-Object {$_.name -eq "$OU"}
 
 
# Retrieve all groups from the specified OU
$groups = Get-ADGroup -Filter * -SearchBase $ouPath.DistinguishedName
 
# Iterate through each group and list its members
foreach ($group in $groups) {
    Write-Host "Group: $($group.Name)"
    Write-Host "Members:"
   
    # Retrieve members of the group
    $members = Get-ADGroupMember -Identity $group -Recursive | Select-Object Name
   
    # List each member
    foreach ($member in $members) {
        Write-Host " - $($member.Name)"
    }
    Write-Host "" # Adds a blank line for readability
}