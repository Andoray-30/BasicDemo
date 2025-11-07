Place the following J-Link command-line tools in this folder (copied from your local J-Link installation):

- JLink.exe
- JLinkGDBServerCL.exe
- JlinkRTTClient.exe

You can run the helper script to copy them automatically (if J-Link is installed):

  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\download-jlink.ps1

Note: Do NOT commit J-Link binaries to a public repository unless licensing permits.