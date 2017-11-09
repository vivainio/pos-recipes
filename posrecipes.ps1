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

function Get-ProcAll() {
    Get-WmiObject Win32_Process | select Handle, Name, CommandLine

}
# e.g. Get-PortProcesses -Pattern 8??? to see all processes listening on 8xxx port range 
function Get-PortProcesses($Pattern) {
    $procs = Get-ProcAll
    $h = @{}
    $procs | % {$h[$_.Handle] = $_}
    $listening = Get-NetTCPConnection|where {$_.LocalPort -like $pattern } | select -ExpandProperty OwningProcess | Sort-Object -Unique 
    $result = $listening | % { $h[$_]  }
    $result
    
}

function Get-Procs() {
    Get-WmiObject Win32_Process
}

Get-PortProcesses 1*
