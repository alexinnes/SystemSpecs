
#Add XAML code inbetween the two @
$inputXML = @"
<Window x:Name="Sytem_Info" x:Class="SystemSpecs.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="System Viewer v1" Height="466.667" Width="1149.561" WindowStyle="ToolWindow">
    <Grid Margin="0,98,0,0">
        <TabControl Margin="10,-51,10,10" Name="TabControl">
            <TabItem Header="BIOS">
                <Grid Background="#FFE5E5E5">
                    <ListView Margin="10" Name="BiosListBox">
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="SMBIOSVersion" DisplayMemberBinding ="{Binding BIOS.SMBIOSBIOSVersion}"/>
                                <GridViewColumn Header="Manufacturer" DisplayMemberBinding ="{Binding BIOS.Manufacturer}"/>
                                <GridViewColumn Header="Name" DisplayMemberBinding ="{Binding BIOS.Name}"/>
                                <GridViewColumn Header="Serial Number" DisplayMemberBinding ="{Binding BIOS.SerialNumber}"/>
                                <GridViewColumn Header="Version" DisplayMemberBinding ="{Binding BIOS.Version}"/>
                            </GridView>
                        </ListView.View>
                    </ListView>
                </Grid>
            </TabItem>
            <TabItem Header="OS">
                <Grid Background="#FFE5E5E5">
                    <ListView Margin="10" Name="OSTextBox">
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="SystemDirectory" DisplayMemberBinding ="{Binding OS.SystemDirectory}"/>
                                <GridViewColumn Header="Organization" DisplayMemberBinding ="{Binding OS.Organization}"/>
                                <GridViewColumn Header="BuildNumber" DisplayMemberBinding ="{Binding OS.BuildNumber}"/>
                                <GridViewColumn Header="SerialNumber" DisplayMemberBinding ="{Binding OS.SerialNumber}"/>
                                <GridViewColumn Header="Version" DisplayMemberBinding ="{Binding OS.Version}"/>
                            </GridView>
                        </ListView.View>
                    </ListView>
                </Grid>
            </TabItem>

            <TabItem Header="System">
                <Grid Background="#FFE5E5E5">
                    <ListView Margin="10" Name="SystemTextBox">
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="Name" DisplayMemberBinding ="{Binding System.Name}"/>
                                <GridViewColumn Header="Domain" DisplayMemberBinding ="{Binding System.Domain}"/>
                                <GridViewColumn Header="Total Physical Memory" DisplayMemberBinding ="{Binding System.TotalPhysicalMemory}"/>
                                <GridViewColumn Header="Model" DisplayMemberBinding ="{Binding System.Model}"/>
                                <GridViewColumn Header="Manufacturer" DisplayMemberBinding ="{Binding System.Manufacturer}"/>
                            </GridView>
                        </ListView.View>
                    </ListView>
                </Grid>
            </TabItem>
            <TabItem Header="HDD">
                <Grid Background="#FFE5E5E5">
                    <ListView Margin="10" Name="HDDTextBox">
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="DeviceID" DisplayMemberBinding ="{Binding DeviceID}"/>
                                <GridViewColumn Header="DriveType" DisplayMemberBinding ="{Binding DriveType}"/>
                                <GridViewColumn Header="VolumeName" DisplayMemberBinding ="{Binding VolumeName}"/>
                                <GridViewColumn Header="Size/GB" DisplayMemberBinding ="{Binding Size}"/>
                                <GridViewColumn Header="FreeSpace/GB" DisplayMemberBinding ="{Binding FreeSpace}"/>

                            </GridView>
                        </ListView.View>
                    </ListView>
                </Grid>
            </TabItem>
            <TabItem Header="CPU">
                <Grid Background="#FFE5E5E5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="17*"/>
                        <ColumnDefinition Width="78*"/>
                    </Grid.ColumnDefinitions>
                    <ListView Margin="10" Name="CPUTextBox" Grid.ColumnSpan="2">
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="DeviceID" DisplayMemberBinding ="{Binding CPU.DeviceID}"/>
                                <GridViewColumn Header="Name" DisplayMemberBinding ="{Binding CPU.Name}"/>
                                <GridViewColumn Header="Caption" DisplayMemberBinding ="{Binding CPU.Caption}"/>
                                <GridViewColumn Header="Max Clock Speed" DisplayMemberBinding ="{Binding CPU.MaxClockSpeed}"/>
                                <GridViewColumn Header="SocketDesignation" DisplayMemberBinding ="{Binding CPU.SocketDesignation}"/>
                                <GridViewColumn Header="Manufacturer" DisplayMemberBinding ="{Binding CPU.Manufacturer}"/>
                            </GridView>
                        </ListView.View>
                    </ListView>
                </Grid>
            </TabItem>
            <TabItem Header="Drivers">
                <Grid Background="#FFE5E5E5">
                    <ListView Margin="10" Name="DriverTextBox">
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="HardwareID" DisplayMemberBinding ="{Binding HardwareID}" Width="auto" />
                                <GridViewColumn Header="DeviceName" DisplayMemberBinding ="{Binding DeviceName}"/>
                                <GridViewColumn Header="Description" DisplayMemberBinding ="{Binding Description}"/>
                                <GridViewColumn Header="Manufacturer" DisplayMemberBinding ="{Binding Manufacturer}"/>
                            </GridView>
                        </ListView.View>
                    </ListView>
                </Grid>
            </TabItem>

        </TabControl>
        <Label Content="System Viewer v1" HorizontalAlignment="Left" Margin="10,-92,0,0" VerticalAlignment="Top" Height="36" Width="257" FontSize="18"/>
    </Grid>
</Window>
"@       
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name)}

#ADD WPF Function/click here
function Get-SystemSpecs
{
    Begin
    {
    $computerSystem = Get-CimInstance CIM_ComputerSystem
    $computerBIOS = Get-CimInstance CIM_BIOSElement
    $computerOS = Get-CimInstance CIM_OperatingSystem
    $computerCPU = Get-CimInstance CIM_Processor
    $computerHDD = Get-CimInstance Win32_LogicalDisk
    $drivers = Get-WmiObject win32_pnpsigneddriver |where{$_.manufacturer -ne "Microsoft"}
    }
    Process
    {
    $computerspecs = New-Object pscustomobject -ArgumentList @{
        System = $computerSystem
        BIOS = $computerBIOS
        OS = $computerOS
        CPU = $computerCPU
        HDD = $computerHDD
        Driver = $drivers
        }
    }
    End
    {
    return $computerspecs
    }
}
$systemspecs = Get-SystemSpecs



$WPF_BiosListBox.Items.Add([pscustomobject]$systemspecs) > 0
$WPF_OSTextBox.Items.Add([pscustomobject]$systemspecs) > 0
$WPF_SystemTextBox.Items.Add([pscustomobject]$systemspecs) > 0

foreach($HDD in $systemspecs.hdd){
$HDDObj = new-object  pscustomobject -ArgumentList @{
    DeviceID = $HDD.DeviceID
    VolumeName = $HDD.VolumeName
    size = "{0:N2}" -f (($HDD.Size)/1gb)
    freespace = "{0:N2}" -f (($HDD.FreeSpace)/1gb)
    drivetype = $HDD.DriveType
}
$WPF_HDDTextBox.Items.Add([pscustomobject]$HDDObj) > 0 

}

$WPF_CPUTextBox.Items.Add([pscustomobject]$systemspecs) > 0

foreach($drivers in $systemspecs.driver){
$DriversObj = New-Object pscustomobject -ArgumentList @{
    DeviceName = $Drivers.devicename
    HardwareID = $Drivers.hardwareid
    Manufacturer = $Drivers.manufacturer
    description = $Drivers.Description
    }
$wpf_DriverTextbox.Items.Add([pscustomobject]$DriversObj) > 0
}



#show the form
$Form.ShowDialog() | out-null


