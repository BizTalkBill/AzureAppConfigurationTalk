using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Microsoft.Extensions.Configuration;

namespace InProcess.Function
{
    public class Demo1a
    {
        private readonly IConfiguration _configuration;

        public Demo1a(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [FunctionName("Demo1a")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            // Read configuration data
            string keyName = "testValue1";
            string message = _configuration[keyName];

            return message != null
                ? (ActionResult)new OkObjectResult(message)
                : new BadRequestObjectResult($"Please create a key-value with the key '{keyName}' in App Configuration.");
        }
    }
}
