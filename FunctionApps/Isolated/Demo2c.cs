using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;

namespace Isolated.Function
{
    public class Demo2c
    {
        private readonly ILogger _logger;
        private readonly IConfiguration _configuration;

        public Demo2c(ILoggerFactory loggerFactory, IConfiguration configuration)
        {
            _logger = loggerFactory.CreateLogger<Demo2c>();
            _configuration = configuration;
        }

        [Function("Demo2c")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            
            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

            // Read configuration section
            string sectionName = "Section";
            var section = _configuration.GetSection(sectionName);

            string results = "Configuration Section = " + sectionName + " contains [";
            foreach (var val in section.GetChildren())
            {
                results += "{ key=" + val.Key + " value=" + val.Value.ToString() + " }";
            }

            response.WriteString(results ?? $"Please create a section with the key '{sectionName}' in Azure App Configuration.");

            return response;
        }
    }
}