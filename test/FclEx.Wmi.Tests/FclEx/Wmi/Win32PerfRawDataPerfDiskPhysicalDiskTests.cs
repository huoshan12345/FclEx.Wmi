namespace FclEx.Wmi;

public class Win32PerfRawDataPerfDiskPhysicalDiskTests
{
    [Fact(Explicit = true)]
    public async Task Test()
    {
        for (var i = 0; i < 5; i++)
        {
            GlobalConstants.CancellationToken.ThrowIfCancellationRequested();

            var items = new ManagementObjectSearcher("SELECT * FROM Win32_PerfRawData_PerfDisk_PhysicalDisk")
                .Get()
                .OfType<ManagementBaseObject>()
                .Select(m => m.ReadAs<Win32_PerfRawData_PerfDisk_PhysicalDisk>());


            foreach (var item in items)
            {
                Output?.WriteLine($"{item.Name}");
            }

            await Task.Delay(TimeSpan.FromSeconds(1));
        }
    }
}