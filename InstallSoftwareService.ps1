. .\SetEnvironmentVariables.ps1

if ((Test-Path ${JAVA_HOME}) -ne $True) {
  echo "`nInstalling Java JDK and JRE with custom folders ..."
  
  $JAVA_INST_ARGS = '/s ADDLOCAL="ToolsFeature,SourceFeature,PublicjreFeature" INSTALLDIR="{0}" /INSTALLDIRPUBJRE="{1}" STATIC=0 AUTO_UPDATE=0 WEB_JAVA=1 WEB_JAVA_SECURITY_LEVEL=H WEB_ANALYTICS=0 EULA=0 REBOOT=0 NOSTARTMENU=0 SPONSORS=0 /L c:\temp\jdk-8u181-windows-x64.log' -f $JAVA_HOME, $JRE_HOME
  
  Start-Process "${JAVA_SOFTWARE_FILE}" $JAVA_INST_ARGS -wait
  echo "Check log file: c:\temp\jdk-8u181-windows-x64.log incase of any issues`n"
  
  echo "`nAdding JAVA_HOME variable to ""System Variables"" ..."
  setx JAVA_HOME "${JAVA_HOME}" -M
  echo "Validation:"
  Get-ChildItem -Path Env: | Where-Object -Property Name -eq 'JAVA_HOME'
  
  echo "`nEdit and add JAVA_HOME to PATH varibale under ""system variables"" ..."
  $path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
  [System.Environment]::SetEnvironmentVariable("PSModulePath", $path +";${JAVA_HOME}\bin", "Machine")
  echo "Validation - check the last portion:"
  $Env:Path
  echo ""
}

echo "`n`nExtracting WLS zip file:"
D:\7z x ${WLS_SOFTWARE_FILE} -o"${WLS_SOFTWARE_DIRECTORY}"
 
if ((Test-Path ${TEMPORARY_DIRECTORY}) -ne $True) {
    New-Item ${TEMPORARY_DIRECTORY} -type directory
}

echo "`n`nCREATING SILENT INSTALL FILES"
$SILENT_FILE = "${TEMPORARY_DIRECTORY}\silent-weblogic.txt"
 
"[ENGINE]
 
#DO NOT CHANGE THIS.
Response File Version=1.0.0.0.0
 
[GENERIC]
 
#Set this to true if you wish to skip software updates
DECLINE_AUTO_UPDATES=true

#My Oracle Support User Name
MOS_USERNAME=

#My Oracle Support Password
MOS_PASSWORD=<SECURE_VALUE>

#If the Software updates are already downloaded and available on your local system, then specify the path 
#to the directory where these patches are available and set SPECIFY_DOWNLOAD_LOCATION to true
AUTO_UPDATES_LOCATION=

#Proxy Server Name to connect to My Oracle Support
SOFTWARE_UPDATES_PROXY_SERVER=

#Proxy Server Port
SOFTWARE_UPDATES_PROXY_PORT=

#Proxy Server Username
SOFTWARE_UPDATES_PROXY_USER=

#Proxy Server Password
SOFTWARE_UPDATES_PROXY_PASSWORD=<SECURE_VALUE>

#The oracle home location. This can be an existing Oracle Home or a new Oracle Home
ORACLE_HOME=${MIDDLEWARE_HOME}
 
#Set this variable value to the Installation Type selected. e.g. WebLogic Server, Coherence, Complete with Examples.
INSTALL_TYPE=WebLogic Server
 
#Provide the My Oracle Support Username. If you wish to ignore Oracle Configuration Manager configuration provide empty string for user name.
MYORACLESUPPORT_USERNAME=
 
#Provide the My Oracle Support Password
MYORACLESUPPORT_PASSWORD=<SECURE VALUE>
 
#Set this to true if you wish to decline the security updates. Setting this to true and providing empty string for
#My Oracle Support username will ignore the Oracle Configuration Manager configuration
DECLINE_SECURITY_UPDATES=true
 
#Set this to true if My Oracle Support Password is specified
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
 
#Provide the Proxy Host
PROXY_HOST=
 
#Provide the Proxy Port
PROXY_PORT=
 
#Provide the Proxy Username
PROXY_USER=
 
#Provide the Proxy Password
PROXY_PWD=<SECURE VALUE>
 
#Type String (URL format) Indicates the OCM Repeater URL which should be of the format [scheme[Http/Https]]://[repeater host]:[repeater port]
COLLECTOR_SUPPORTHUB_URL=" | Out-File ${SILENT_FILE}
 
$CONTENTS = Get-Content ${SILENT_FILE}
$UTF_8_NO_BOM_ENCODING = New-Object System.Text.UTF8Encoding($False)
[System.IO.File]::WriteAllLines(${SILENT_FILE}, ${CONTENTS}, ${UTF_8_NO_BOM_ENCODING})
 
echo "`n`nINSTALLING WEBLOGIC SERVER..."
$SILENT_FILE = ${SILENT_FILE}.Replace("\","\\")
& ${JAVA_HOME}\bin\java.exe -Xms512m -Xmx1024m -jar ${WLS_SOFTWARE_DIRECTORY}\${WEBLOGIC_JAR_FILE_NAME} -silent -responseFile ${SILENT_FILE}

echo ""