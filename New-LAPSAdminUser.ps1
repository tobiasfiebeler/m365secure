<#
.SYNOPSIS
Create a local admin user for LAPS Management
.DESCRIPTION
The script creates a local user with the name defined in variable $lapsAdminName and a random password with the length defined in $lapsAdminTempPasswordLenght.
The user is added to the local Administrators group identified by the SID of the group due to language dependencies. 
.PARAMETER <Parameter_Name>
[string] $lapsAdminName,
[int] $lapsAdminTempPasswordLenght,
[boolean] $verboseOutputEnabled
.INPUTS
<None>
.OUTPUTS
<None>
.NOTES
   Version:        0.1
   Author:         Tobias Fiebeler
   Creation Date:  Tuesday, April 25th 2023, 10:41:40 am
   File: New-LAPSAdminUser.ps1
   Copyright (c) 2023 itacs GmbH
HISTORY:
Date      	          By	Comments
----------	          ---	----------------------------------------------------------

.LINK
   https://www.itacs.de
   https://blog.m365secure.de

.COMPONENT
 Required Modules: None

.LICENSE
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the Software), to deal
in the Software without restriction, including without limitation the rights
to use copy, modify, merge, publish, distribute sublicense and /or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#requires -runasadministrator 
[CmdletBinding()]
param (
    [string]$lapsAdminName = '<please insert Name here>',
    [int]$lapsAdminTempPasswordLenght = 16,
    [boolean]$verboseOutputEnabled = $false
)
#---------------------------------------------------------[Variables]--------------------------------------------------------
#
#---------------------------------------------------------[Functions]--------------------------------------------------------
# Create a new local user and add the account to the local admin group by SID reference
function New-LocalAdmin {
    [CmdletBinding()]
    param (
        [string] $Name,
        [securestring] $Password,
        [boolean] $verboseOutputEnabled = $verboseOutputEnabled
    )    
    begin {
    }    
    process {
        try {
            $NewUser = New-LocalUser -Name $Name -Password $Password -FullName $Name -Description 'LAPS Managed Admin' -Verbose:$verboseOutputEnabled
            if($verboseOutputEnabled){Write-Verbose ("{0} local user crated" -f $Name)}
            $localAdminGroupName = (Get-LocalGroup -SID 'S-1-5-32-544').Name
            Add-LocalGroupMember -Group $localAdminGroupName -Member $NewUser.Name -Verbose:$verboseOutputEnabled
            if($verboseOutputEnabled){Write-Verbose ("{0} added to the local administrator group" -f $NewUser.Name)}
        }
        catch {
            $message = $_
            Write-Warning ("An error occured with {0}" -f $message)
        } 
    }    
    end {
    }
}
#Create a random password for new user. All characters are allowed except "\"
function New-Password {
    [CmdletBinding()]
    param (
        [int]$Passwordlengh,
        [boolean] $verboseOutputEnabled = $verboseOutputEnabled
    )
    begin {
    }
    process {
        $pw = (-join (((33..91)+(93..126)) | Get-Random -Count $Passwordlengh | ForEach-Object {[char]$_}))
        if($verboseOutputEnabled){Write-Verbose ("The password is {0}" -f $pw)}
        $spw = ConvertTo-SecureString $pw -AsPlainText -Force        
    }
    end {
        Remove-Variable -Name 'pw' | Out-Null
        return $spw
    }    
}

#Create new Account
$password = New-Password -Passwordlengh $lapsAdminTempPasswordLenght -Verbose:$verboseOutputEnabled
New-LocalAdmin -Name $lapsAdminName -Password $password -Verbose:$verboseOutputEnabled