<#
Program: ConvertBIRT
Author: Bruce Jernell

Purpose: The purpose of this program is to convert BIRT rptdesign files to SQL
queries.  This allows for easy import/parsing of the raw data from OpCon reports.

You can use virtually the same commandline that exists now for automated BIRT
report except you will need to answer the "birtpath" and "runas" parameters.


Changelog                                                      Date
-----------------------------------------------------------------------------------
Version 1.0                                                    3/14/2018
Version 1.1 - added outputpath param and fixed a few bugs      7/16/2020

#>

param(
    $skddate,  #Same as current BIRT
    $histarc_skddate,  #Same as current BIRT
    $history_skddate,  #Same as current BIRT
    $audithst_sqldate,  #Same as current BIRT
    $machs_machid,  #Same as current BIRT
    $machgrps_machgrpid,  #Same as current BIRT
    $skdid,  #Same as current BIRT
    $deptid,  #Same as current BIRT
    $tagname,  #Same as current BIRT
    $birtpath = "C:\Program Files\OpConxps\SAM\BIRT\ReportEngine\OpConXPS_Reports", #Path to the BIRT report directory
    $outputpath = "C:\Bruce\Roundtables", # Path to output raw SQL statements
    $o,  #Same as current BIRT
    $runas,    #User permissions to simulate when building query
    $opconmodule = "C:\ProgramData\OpConxps\Demo\OpCon.psm1", #Path to opcon module file
    $r,  #Same as current BIRT
    $report = "Estimated Run Time by Schedule", #Name of report to run
    $msgin,  #Path to msgin directory
    $extuser,#External event user name
    $extpword, #External event password
    $email, #Email address to send report
    $run = "No", #Yes/No whether to submit an OpCon event to run the report
    $url, #OpCon API url
    $token #OpCon API token
)

#If msgin argument isn't specified and run=YES then import OpCon module
if((!$msgin) -and ($run -eq "yes"))
{
    if(Test-Path $opconmodule)
    {
        #Verify PS version is at least 3.0
        if($PSVersionTable.PSVersion.Major -gt 3)
        {
            #Import needed module
            Import-Module -Name $opconmodule #-Verbose  #If you uncomment this option you will see a list of all functions      
        }
        else
        {
            Write-Host "Powershell version needs to be 3.0 or higher!"
            Exit 100
        }
    }
    else
    {
        Write-Host "Unable to import SMA API module!"
        Exit 100
    }
}
elseif($msgin -and ($run -eq "yes"))
{
    if(!(test-path $msgin))
    {
        Write-Host "Invalid MSGIN path!!"
        Exit 101
    }
}

#Verifies BIRT path is reachable
if(!(test-path $birtpath))
{
    Write-Host "Invalid Birt File path specified!"
    Exit 102
}

#Setup dates arguments for SQL
if($skddate -or $histarc_skddate -or $history_skddate)
{
    if($skddate)
    { $dates = $skddate }
    elseif($histarc_skddate)
    { $dates = $histarc_skddate }
    elseif($history_skddate)
    { $dates = $history_skddate }

    $darray = $dates.split(",")
    $dlist = ""
    for($x = 0;$x -lt $darray.length;$x++)
    {
        if($x -lt ($darray.length -1))
        {
            $dlist = $dlist + "cast(cast('" + $darray[$x] + "' as smalldatetime) as int)+2,"
        }
        else
        {
            $dlist = $dlist + "cast(cast('" + $darray[$x] + "' as smalldatetime) as int)+2"
        }
    }
}
elseif($audithst_sqldate) #This parameter doesn't need to be converted
{
    $darray = $audithst_sqldate.split(",")
    $dlist = ""
    for($x = 0;$x -lt $darray.length;$x++)
    {
        if($x -lt ($darray.length -1))
        {
            $dlist = "'" + $dlist + "',"
        }
        else
        {
            $dlist = "'" + $dlist + "'"
        }
    }
}

#Setup schedules dates for sql
if($skdid)
{
    $sarray = $skdid.split(",")
    $slist = ""
    for($x = 0;$x -lt $sarray.length;$x++)
    {
        if($x -lt ($sarray.length -1))
        {
            $slist = $slist + "'" + $sarray[$x] + "',"
        }
        else
        {
            $slist = $slist + "'" + $sarray[$x] + "'"
        }
    }
    $slist = $slist.Replace("'*'","SELECT SKDNAME FROM SNAME")
    $slist = $slist.Replace("'SKDID>0'","SELECT SKDNAME FROM SNAME")
}

#Setup department ids for sql
if($deptid)
{
    $deptarray = $deptid.split(",")
    $deptlist = ""
    for($x = 0;$x -lt $deptarray.length;$x++)
    {
        if($x -lt ($deptarray.length -1))
        {
            $deptlist = $deptlist + "'" + $deptarray[$x] + "',"
        }
        else
        {
            $deptlist = $deptlist + "'" + $deptarray[$x] + "'"
        }
    }
    $deptlist = $deptlist.Replace("'*'","SELECT DEPTNAME FROM DEPTS")
    $deptlist = $deptlist.Replace("'DEPTID>0'","SELECT DEPTNAME FROM DEPTS")
    $deptlist = $deptlist.Replace("'<All Departments>'","SELECT DEPTNAME FROM DEPTS")
}

#Setup tags for query
if($tagname)
{
    $tagarray = $tagname.split(",")
    $taglist = ""
    for($x = 0;$x -lt $tagarray.length;$x++)
    {
        if($x -lt ($tagarray.length -1))
        {
            $taglist = $taglist + "'" + $tagarray[$x] + "',"
        }
        else
        {
            $taglist = $taglist + "'" + $tagarray[$x] + "'"
        }
    }
}

#Setup machines for query
if($machs_machid)
{
    $macharray = $machs_machid.split(",")
    $machlist = ""
    for($x = 0;$x -lt $macharray.length;$x++)
    {
        if($x -lt ($macharray.length -1))
        {
            $machlist = $machlist + "'" + $macharray[$x] + "',"
        }
        else
        {
            $machlist = $machlist + "'" + $macharray[$x] + "'"
        }
    }
    $machlist = $machlist.Replace("'*'","SELECT MACHNAME FROM MACHS")
    $machlist = $machlist.Replace("'MACHS_MACHID>0'","SELECT MACHNAME FROM MACHS")
}

#Setup machines groups for query
if($machgrps_machgrpid)
{
    $machgrparray = $machgrps_machgrpid.split(",")
    $machgrplist = ""
    for($x = 0;$x -lt $machgrparray.length;$x++)
    {
        if($x -lt ($machgrparray.length -1))
        {
            $machgrplist = $machgrplist + "'" + $machgrparray[$x] + "',"
        }
        else
        {
            $machgrplist = $machgrplist + "'" + $machgrparray[$x] + "'"
        }
    }
    $machgrplist = $machgrplist.Replace("'*'","SELECT MACHGRP FROM MACHGRPS")
    $machgrplist = $machgrplist.Replace("'MACHGRPS_MACHID>0'","SELECT MACHGRP FROM MACHGRPS")
}

#Gets the report query and runs the job in OpCon
if(!$r)
{
    $filter = "*.rptdesign"
}
else
{
    $filter = $r + ".rptdesign"
}

#Parses the BIRT report file/s and retrieve the SQL query
Get-ChildItem $birtpath -Filter $filter | 
Foreach-Object {
    $details = [xml] (Get-Content -Path $_.FullName)
    $reportname = ($details.report.'text-property'.'#text')
    if($reportname -like "*/*")
    { $reportname = $reportname.Replace("/","-") }
    

    if(($report -eq $reportname) -or (!$report))
    {
        $filter = $details.report.'data-sets'.'oda-data-set' | Where-Object { $_.name -like "Report*" }
        $sql = ($filter.'xml-property' | Where-Object{ $_.name -eq "queryText" }).'#cdata-section'
        
        if($sql)
        { 
            Write-Host "-- Building SQL query for report: $reportname -- `r`n"
            #Write-Host $sql
            #Write-Host "`r`n-----------------------------------------------------------------------------`r`n`r`n"

            #These are replacements needed to have the SQL query work, normally they are replaced as inputs
            $sql = $sql.Replace('$(SKDDATE)','(' + $dlist + ')')
            $sql = $sql.Replace('$(SKDID)','(SELECT SKDID FROM SNAME WHERE SKDNAME IN (' + $slist + '))')
            $sql = $sql.Replace('$(DEPTID)','(SELECT DEPTID from DEPTS WHERE DEPTNAME IN (' + $deptlist + '))')
            $sql = $sql.Replace('$(User_Id)',"(SELECT USERID from USERS WHERE USERSIGNON = '" + $runas + "')")
            $sql = $sql.Replace('$(CALDESC_CALID)','(SELECT CALID FROM CALDESC WHERE CALNAME IN (' + $callist + '))')
            $sql = $sql.Replace('$(TAGNAME)','(' + $taglist + ')')
            $sql = $sql.Replace('$(SKDDATESINGLE)','(' + $dlist + ')')
            $sql = $sql.Replace('$(HISTORY_SKDDATE)','(' + $dlist + ')')
            $sql = $sql.Replace('$(HISTARC_SKDDATE)','(' + $dlist + ')')
            $sql = $sql.Replace('$(AUDITHST_SQLDATE)','(' + $dlist + ')')
            $sql = $sql.Replace('$(MACHS_MACHID)','(SELECT MACHID FROM MACHS WHERE MACHNAME IN (' + $machlist + '))')
            $sql = $sql.Replace('$(MACHS_MACHID)','(SELECT MACHGRPID FROM MACHGRPS WHERE MACHGRP IN (' + $machgrplist + '))')

            #Outputs query/s to a file (this is the file that would be run by a subsequent process
            $sql | Out-File -filepath "$outputpath\$reportname.sql"  #Update to $reportname from $report
            $finalpath = ("$o").Replace("\","\\")
            
            #Will send an event to OpCon through MSGIN or the API to run the query
            if($run -eq "yes")
            {   
                #If a msgin path was provided, send the event via msgin
                if($msgin)
                {
                    $opconevent = '$JOB:ADD,' + (Get-Date -Format "MM/dd/yyyy") + ',ADHOC,ONREQUEST,REPORT=' + $reportname + ';FILE=' + "$birtpath\$reportname.sql;OUTPUT=$outputpath;EMAIL=$email,$extuser,$extpword" #replaced report with reportname
                    $opconevent | Out-File -filepath $msgin
                }
                else #Send the job add through the API
                {
                    $jsonpath = ("$birtpath\$reportname.sql").Replace("\","\\") #replaced report with reportname
                    OpCon_ScheduleAction -url $url -token $token -sname "ADHOC" -jname "RUN REPORT" -jfreq "ONREQUEST" -action "JOB:ADD" -instprops "REPORT=$reportname;FILE=$jsonpath;OUTPUT=$outputpath;EMAIL=$email"  #replaced report with reportname
                }

                Exit
            }
        }
    }
}
