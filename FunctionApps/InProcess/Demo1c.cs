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
    public class Demo1c
    {
        private readonly IConfiguration _configuration;

        public Demo1c(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [FunctionName("Demo1c")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            // Read configuration section
            string sectionName = "Section";
            var section = _configuration.GetSection(sectionName);

            string results = "Configuration Section = " + sectionName + " contains [";
            foreach (var val in section.GetChildren())
            {
                results += "{ key=" + val.Key + " value=" + val.Value.ToString() + " }";
            }

            return section != null
                ? (ActionResult)new OkObjectResult(results)
                : new BadRequestObjectResult($"Please create a section with the key '{sectionName}' in App Configuration.");
        }
    }
}