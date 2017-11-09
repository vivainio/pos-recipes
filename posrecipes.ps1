function DllInfo($path) 
{

    $r = @{}
    $r.Path = $path
    $r.Ver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path.FullName).ProductVersion
    return $r
}

function Get-DllVersions($root) {
    $dlls = Get-ChildItem -Recurse -Include "*.dll","*.exe" $root 

    $versions = $dlls | foreach { DllInfo($_) } | Sort-Object { $_.Path.BaseName } | `
        Select @{Name="Name"; Expression= { $_.Path.Name }}, `
               @{Name="Ver"; Expression= { $_.Ver}}, `
               @{Name="Dir"; Expression= { $_.Path.DirectoryName}}
    $versions
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

# Extract references from csproj
function Import-CsDeps ($file) {
    $x = [xml](gc $file)
    $x.Project.ItemGroup.Reference
}