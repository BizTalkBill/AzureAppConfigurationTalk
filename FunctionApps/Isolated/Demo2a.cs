using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;

namespace Isolated.Function
{
    public class Demo2a
    {
        private readonly ILogger _logger;
        private readonly IConfiguration _configuration;

        public Demo2a(ILoggerFactory loggerFactory, IConfiguration configuration)
        {
            _logger = loggerFactory.CreateLogger<Demo2a>();
            _configuration = configuration;
        }

        [Function("Demo2a")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            
            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

            // Read configuration data
            string keyName = "testValue1";
            string message = _configuration[keyName];

            response.WriteString(message ?? $"Please create a key-value with the key '{keyName}' in Azure App Configuration.");

            return response;
        }
    }
}
