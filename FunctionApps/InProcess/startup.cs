using System;
using Azure.Identity;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;

[assembly: FunctionsStartup(typeof(InProcess.Startup))]

namespace InProcess
{
    class Startup : FunctionsStartup
    {
        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
        {
            string AppConfigurationEndpoint = Environment.GetEnvironmentVariable("AppConfigurationEndpoint");
            string AppConfigurationEnvironment = Environment.GetEnvironmentVariable("AppConfigurationEnvironment");
            string visualStudioTenantId = Environment.GetEnvironmentVariable("visualStudioTenantId");

            var azureCredentialOptions = new DefaultAzureCredentialOptions();
            if (!string.IsNullOrEmpty(visualStudioTenantId))
            {
                azureCredentialOptions.VisualStudioTenantId = visualStudioTenantId;
            }
            var credentials = new DefaultAzureCredential(azureCredentialOptions);

            builder.ConfigurationBuilder.AddAzureAppConfiguration((options =>
            {
            options.Connect(new Uri(AppConfigurationEndpoint), credentials)
            .ConfigureKeyVault(kv =>
            {
                kv.SetCredential(credentials);
            })
            .Select(KeyFilter.Any, LabelFilter.Null)
            .Select(KeyFilter.Any, AppConfigurationEnvironment);
            }));
        }

        public override void Configure(IFunctionsHostBuilder builder)
        {
        }
    }
}