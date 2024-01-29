
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