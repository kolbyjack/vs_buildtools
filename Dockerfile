# escape=`

# Use the latest Windows Server Core image with .NET Framework 4.8.
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Add an environment variable for the visual studio buildtools bootstrapper version.
ENV VS_BUILDTOOLS=16.10.31321.278

# Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

# Install Build Tools with the Microsoft.VisualStudio.Workload.VCTools workload, excluding workloads and components with known issues.
RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --includeRecommended `
    --installPath C:\BuildTools `
    --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools `
    --add Microsoft.VisualStudio.Workload.MSBuildTools `
    --add Microsoft.VisualStudio.Workload.NetCoreBuildTools `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Component.VC.ATL `
    --add Microsoft.VisualStudio.Component.VC.CLI.Support `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
    --remove Microsoft.VisualStudio.Component.Windows81SDK `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

# Install chocolatey
ADD https://chocolatey.org/install.ps1 C:\TEMP\chocolatey_install.ps1

RUN "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -NoProfile `
    -InputFormat None `
    -ExecutionPolicy Bypass `
    C:\TEMP\chocolatey_install.ps1

RUN SETX PATH "%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Install chocolatey packages
COPY chocolatey.config C:\TEMP\chocolatey.config
RUN choco feature enable -n allowGlobalConfirmation
RUN choco install C:\TEMP\chocolatey.config || TYPE C:\ProgramData\chocolatey\logs\chocolatey.log

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
