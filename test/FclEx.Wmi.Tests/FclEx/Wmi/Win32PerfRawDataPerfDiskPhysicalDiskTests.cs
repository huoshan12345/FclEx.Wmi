namespace FclEx.Wmi;

public class Win32PerfRawDataPerfDiskPhysicalDiskTests(ITestOutputHelper output)
{
    [LocalOnlyFact]
    public async Task Test()
    {
        for (var i = 0; i < 5; i++)
        {
            var items = new ManagementObjectSearcher("SELECT * FROM Win32_PerfRawData_PerfDisk_PhysicalDisk")
                .Get()
                .OfType<ManagementBaseObject>()
                .Select(m => m.ReadAs<Win32_PerfRawData_PerfDisk_PhysicalDisk>());


            foreach (var item in items)
            {
                output.WriteLine($"{item.Name}");
            }

            await Task.Delay(TimeSpan.FromSeconds(1));
        }
    }
}