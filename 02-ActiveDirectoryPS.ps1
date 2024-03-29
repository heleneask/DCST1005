Get-Command -Module ActiveDirectory | Where-Object {$_.name -like "*user*"}
Get-Command -Module ActiveDirectory | Where-Object {$_.name -like "*group*"}
Get-Command -Module ActiveDirectory | Where-Object {$_.name -like "*OrganizationalUnit*"}

New-ADOrganizationalUnit "TestOU" `
            -Description "TEst for å sjekk at cmdlet fungerer" `
            -ProtectedFromAccidentalDeletion:$false
Get-ADOrganizationalUnit -Filter * | Select-Object name
Get-Help Remove-ADOrganizationalUnit -Online
Get-ADOrganizationalUnit -Filter * | Where-Object {$_.name -eq "TestOU"} | Remove-ADOrganizationalUnit -Recursive -Confirm:$false


#For bedrift InfraIT
$lit_users = "InfraIT_Users"
$lit_groups = "InfraIT_Groups"
$lit_computers = "InfraIT_Computers"

$topOUs = @($lit_users,$lit_groups,$lit_computers )
$departments = @('HR','IT','Sales','Finance','Consultants')

foreach ($ou in $topOUs) {
    New-ADOrganizationalUnit $ou -Description "Top OU for InfraIT" -ProtectedFromAccidentalDeletion:$false
    $topOU = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.name -eq "$ou"}
        foreach ($department in $departments) {
            New-ADOrganizationalUnit $department `
                        -Path $topOU.DistinguishedName `
                        -Description "Deparment OU for $department in topOU $topOU" `
                        -ProtectedFromAccidentalDeletion:$false
        }
}


foreach ($department in $departments) {
    $path = Get-ADOrganizationalUnit -Filter * | 
            Where-Object {($_.name -eq "$department") `
            -and ($_.DistinguishedName -like "OU=$department,OU=$lit_groups,*")}
    New-ADGroup -Name "g_$department" `
                -SamAccountName "g_$department" `
                -GroupCategory Security `
                -GroupScope Global `
                -DisplayName "g_$department" `
                -Path $path.DistinguishedName `
                -Description "$department group"
}

New-ADGroup -name "g_all_employee" `
            -SamAccountName "g_all_employee" `
            -GroupCategory Security `
            -GroupScope Global `
            -DisplayName "g_all_employee" `
            -path "OU=InfraIT_Groups,DC=InfraIT,DC=sec" `
            -Description "all employee"


 

Get-Help New-AdUSer -Online

$password = Read-Host -Prompt "EnterPassword" -AsSecureString
New-ADUser -Name "Hans Hansen" `
            -GivenName "Hans" `
            -Surname "Hansen" `
            -SamAccountName  "hhansen" `
            -UserPrincipalName  "hhansen@core.sec" `
            -Path "OU=IT,OU=LearnIT_Users,DC=core,DC=sec" `
            -AccountPassword $Password `
            -Enabled $true


# HUSK å vis til egen csv fil med brukere (-path viser her en type windows-path)
$users = Import-Csv -Path 'C:\git-projects\DCST1005\users.csv' -Delimiter ";"

foreach ($user in $users) {
    New-ADUser -Name $user.DisplayName `
                -GivenName $user.GivenName `
                -Surname $user.Surname `
                -SamAccountName  $user.username `
                -UserPrincipalName  $user.UserPrincipalName `
                -Path $user.path `
                -AccountPassword (convertto-securestring $user.password -AsPlainText -Force) `
                -Department $user.department `
                -Enabled $true
}

#advanced med særnorske karakterer

$users = Import-Csv -Path 'C:\git-projects\DCST1005\users_adv.csv' -Delimiter ";"

$exportusers = 'C:\git-projects\DCST1005\users_final.csv'

function New-UserPassword {
    param (
        [int]$length = 12
    )
    $characterSet = 37..126 | Where-Object { $_ -ne 59 } | ForEach-Object { [char]$_ }
    $password = ''
    1..$length | ForEach-Object {
        $password += $characterSet | Get-Random
    }
}

Get-ADOrganizationalUnit -Filter * -Properties CanonicalName | ForEach-Object {
    $ou = $_
    Write-Host "OU: $($ou.Name), Path: $($ou.DistinguishedName)"
    # Get and display user objects in the OU
    Get-ADUser -Filter * -SearchBase $ou.DistinguishedName | ForEach-Object {
        Write-Host "`tUser: $($_.Name)"
    }
    # Get and display group objects in the OU
    Get-ADGroup -Filter * -SearchBase $ou.DistinguishedName | ForEach-Object {
        Write-Host "`tGroup: $($_.Name)"
    }
    Write-Host ""
}



#
foreach ($user in $users) {
    Remove-ADUser -Identity $user.username -Confirm:$false
}