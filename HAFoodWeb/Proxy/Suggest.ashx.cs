using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Web;

namespace HAFoodWeb.Proxy
{
    public class Suggest : HttpTaskAsyncHandler
    {
        private static readonly string ApiBase =
            (ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").TrimEnd('/');

        public override async System.Threading.Tasks.Task ProcessRequestAsync(HttpContext context)
        {
            try { ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12; } catch { }

            context.Response.ContentType = "application/json; charset=utf-8";
            context.Response.Cache.SetCacheability(HttpCacheability.Public);
            context.Response.Cache.SetMaxAge(TimeSpan.FromSeconds(60));
            context.Response.AddHeader("Access-Control-Allow-Origin", "*");

            var q = (context.Request["q"] ?? "").Trim();
            if (string.IsNullOrEmpty(ApiBase))
            {
                context.Response.StatusCode = 200;
                context.Response.Write("{\"items\":[]}");
                return;
            }

            var url = ApiBase + "/api/search/suggest?q=" + Uri.EscapeDataString(q);

            try
            {
                var req = (HttpWebRequest)WebRequest.Create(url);
                req.Method = "GET";
                req.Accept = "application/json";
                req.UserAgent = "HAFoodWeb/1.0 (+https://hafood.id.vn)";
                req.Timeout = 15000;
                req.ReadWriteTimeout = 15000;

                using (var resp = (HttpWebResponse)await req.GetResponseAsync())
                {
                    context.Response.StatusCode = (int)resp.StatusCode;
                    using (var s = resp.GetResponseStream())
                    {
                        if (s != null)
                        {
                            s.CopyTo(context.Response.OutputStream);
                            context.Response.Flush();
                        }
                        else
                        {
                            context.Response.Write("{\"items\":[]}");
                        }
                    }
                }
            }
            catch
            {
                context.Response.StatusCode = 200;
                context.Response.Write("{\"items\":[]}");
            }
        }

        public override bool IsReusable { get { return true; } }
    }
}
