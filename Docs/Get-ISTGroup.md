Get-ISTGroup
===================

## SYNOPSIS
Retrieve group(s)

## SYNTAX
```powershell
Get-ISTGroup [-GroupType <String[]>] [-SchoolType <String[]>] [-Parent <Guid[]>] [-ExpandAssignmentRole] [-StartDateOnOrBefore <String>] [-StartDateOnOrAfter <String>] [-EndDateOnOrBefore <String>] [-EndDateOnOrAfter <String>] [<CommonParameters>]



Get-ISTGroup [-Id <Guid>] [-ExpandAssignmentRole] [<CommonParameters>]



Get-ISTGroup [-LookUp <Guid[]>] [-ExpandAssignmentRole] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will let you retrieve one or more groups from EduCloud based on what information the parameters are feed with.

## PARAMETERS
### -GroupType &lt;String[]&gt;
Filter groups on what type of group.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -SchoolType &lt;String[]&gt;
Filter groups on what type of school it is.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -Parent &lt;Guid[]&gt;
Retrieve all groups connected to specified organisation.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -Id &lt;Guid&gt;
Retrieve one specific group based on it's id
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -LookUp &lt;Guid[]&gt;
Send an array of group ids to the API. This is useful when you need to retrieve many groups and don't want to loop with the Id parameter.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -ExpandAssignmentRole &lt;SwitchParameter&gt;
Whether or not to retrieve assignment role connected to the group(s)
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -StartDateOnOrBefore &lt;String&gt;
Must be in RFC3339 format - Will only retrieve duty/duties that either has the same starting date or started before
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -StartDateOnOrAfter &lt;String&gt;
Must be in RFC3339 format - Will only retrieve duty/duties that either has the same starting date or starts after
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -EndDateOnOrBefore &lt;String&gt;
Must be in RFC3339 format - Will only retrieve duty/duties that either has the same ending date or ends before
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -EndDateOnOrAfter &lt;String&gt;
Must be in RFC3339 format - Will only retrieve duty/duties that either has the same ending date or ends after
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

## INPUTS


## OUTPUTS


## NOTES
Author: Simon Mellergård | It-center, Värnamo kommun

## EXAMPLES
### EXAMPLE 1
```powershell
PS C:\>Get-ISTGroup -GroupType Klass

# In this example, you will retrieve all groups where group type match "Klass". Note that depending on your organisation this might take a while.
```

 
### EXAMPLE 2
```powershell
PS C:\>Get-ISTGroup -GroupType Undervisning -Parent 90000a8a-e63c-4b67-9626-7092a04eddb9

# This example will retrieve all groups where group type match "Undervisning" and are connected to specified organisation id.
```

 
### EXAMPLE 3
```powershell
PS C:\>Get-ISTGroup -Parent 5237567b-06fd-4986-8aff-3806e611d82d

# Here you will retrieve all groups that are connected to specified organisation id.
```

 
### EXAMPLE 4
```powershell
PS C:\>Get-ISTGroup -Id caeb3b49-a29e-4ab2-9321-8a8a2ff66489 -ExpandAssignmentRole

# This example will retrieve one specific group along with, if there are any, expanded assignment role.
```

 
### EXAMPLE 5
```powershell
PS C:\>$GroupIds = @(

"15d05368-563c-4d6a-88c2-d136dfd12eff",
    "8ab63dc9-8069-4442-b046-d226275acc5a",
    "dd1a17f6-845e-4bce-a958-b8570356abe9"
)
Get-ISTGroup -LookUp $GroupIds -ExpandAssignmentRole
# This example is useful when you need to retrieve many groups with specific ids so you don't need to loop through the Id parameter.
```

 
### EXAMPLE 6
```powershell
PS C:\>$Today = Get-Date -Format yyyy-MM-dd

Get-ISTGroup -GroupType Undervisning -StartDateOnOrBefore $Today -EndDateOnOrAfter $Today
# This example will retrieve all groups in your organisation that matches group type "Undervisning" and also filter out groups that meet the start/end date critera provided.
```


