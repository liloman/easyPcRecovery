ComputerName = "."

Set wmiServices = GetObject("winmgmts:{impersonationLevel=Impersonate}!//" & ComputerName)

Set logicalDisks = wmiServices.ExecQuery _
("ASSOCIATORS OF {Win32_LogicalDisk.DeviceID="""&_
 Wscript.Arguments.Item(0) & """} " & _
 "WHERE AssocClass = Win32_LogicalDiskToPartition" )

For Each logicalDisk In logicalDisks
  WScript.Echo logicalDisk.Name
Next   
  
