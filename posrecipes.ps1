function DllInfo($path) 
{

    $r = @{}
    $r.Path = $path
    $r.Ver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path.FullName).ProductVersion
    return $r
}

function Get-DllVersions($root) {
    $dlls = Get-ChildItem -Recurse -Include "*.dll","*.exe" $root 

    #write-host $dlls

    $versions = $dlls | foreach { DllInfo($_) } | Sort-Object { $_.Path.BaseName } | foreach { 
        ("{0} '{1}' {2}" -f $_.Path.Name,$_.Ver,$_.Path.DirectoryName) 
    
    } | write-host

}

# Get all processes along with command lines
function Get-ProcAll() {
    Get-WmiObject Win32_Process | select Handle, Name, CommandLine

}
# e.g. Get-PortProcesses -Pattern 8??? to see all processes listening on 8xxx port range 
function Get-PortProcesses($Pattern) {
    $procs = Get-ProcAll
    $h = @{}
    $procs | % { $h.Add($_.Handle.ToString(), $_) }
    $listening = Get-NetTCPConnection|where {$_.LocalPort -like $pattern } | select -ExpandProperty OwningProcess | Sort-Object -Unique 
    $result = $listening | % {
        $procinfo = $h.Get_Item($_.ToString())
        $procInfo 
    }
    $result
    
}

function Get-Procs() {
    Get-WmiObject Win32_Process
}

