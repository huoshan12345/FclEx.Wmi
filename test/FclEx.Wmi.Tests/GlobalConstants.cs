public static class GlobalConstants
{
    public static ITestOutputHelper? Output => TestContext.Current.TestOutputHelper;
    public static CancellationToken CancellationToken => TestContext.Current.CancellationToken;
}