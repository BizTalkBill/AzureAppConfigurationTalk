using Azure.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Microsoft.Extensions.Hosting;

string AppConfigurationEndpoint = Environment.GetEnvironmentVariable("AppConfigurationEndpoint");
string AppConfigurationEnvironment = Environment.GetEnvironmentVariable("AppConfigurationEnvironment");
string visualStudioTenantId = Environment.GetEnvironmentVariable("visualStudioTenantId");

var azureCredentialOptions = new DefaultAzureCredentialOptions();
if (!string.IsNullOrEmpty(visualStudioTenantId))
{
    azureCredentialOptions.VisualStudioTenantId = visualStudioTenantId;
}
var credentials = new DefaultAzureCredential(azureCredentialOptions);

var host = new HostBuilder()
    .ConfigureAppConfiguration(builder =>
    {
        builder.AddAzureAppConfiguration((options =>
        {
            options.Connect(new Uri(AppConfigurationEndpoint), credentials)
            .ConfigureKeyVault(kv =>
            {
                kv.SetCredential(credentials);
            })
            .Select(KeyFilter.Any, LabelFilter.Null)
            .Select(KeyFilter.Any, AppConfigurationEnvironment);
        }));
    })
    .ConfigureFunctionsWorkerDefaults()
    .Build();

host.Run();
