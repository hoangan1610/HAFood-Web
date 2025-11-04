using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using System.Web;
using System.Web.SessionState;

namespace HAFoodWeb.Proxy
{
    // Chỉ còn chức năng ASK. Không còn upload.
    public class ChatProxy : HttpTaskAsyncHandler, IRequiresSessionState
    {
        private static readonly JsonSerializerSettings JsonSettings = new JsonSerializerSettings
        {
            NullValueHandling = NullValueHandling.Ignore
        };

        public override async Task ProcessRequestAsync(HttpContext ctx)
        {
            var swAll = Stopwatch.StartNew();

            ctx.Response.ContentType = "application/json; charset=utf-8";
            ctx.Response.Cache.SetNoStore();
            ctx.Response.TrySkipIisCustomErrors = true;

            var action = (ctx.Request["action"] ?? "").Trim().ToLowerInvariant();
            var token = ctx.Session?["UserToken"] as string; // khách chưa login vẫn dùng được

            Debug.WriteLine($"[ChatProxy] >>> Start URL={ctx.Request.Url} Action='{action}' Method={ctx.Request.HttpMethod} HasToken={(token != null)}");

            try
            {
                switch (action)
                {
                    case "ask":
                        await HandleAskAsync(ctx, token).ConfigureAwait(false);
                        break;

                    default:
                        Debug.WriteLine($"[ChatProxy] !!! Unknown action '{action}'");
                        await WriteJson(ctx, new ApiBaseResponse { Success = false, Message = "Action không hợp lệ" }, 400).ConfigureAwait(false);
                        break;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[ChatProxy] !!! Exception: {ex}");
                await WriteJson(ctx, new ApiBaseResponse { Success = false, Code = "SERVER_ERROR", Message = ex.Message }, 500).ConfigureAwait(false);
            }
            finally
            {
                swAll.Stop();
                Debug.WriteLine($"[ChatProxy] <<< Done. TotalElapsed={swAll.ElapsedMilliseconds}ms");
            }
        }

        private static string Trunc(string s, int max = 600)
            => string.IsNullOrEmpty(s) ? s : (s.Length <= max ? s : s.Substring(0, max) + $" ...(+{s.Length - max} chars)");

        private async Task HandleAskAsync(HttpContext ctx, string token)
        {
            if (!string.Equals(ctx.Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase))
            {
                await WriteJson(ctx, new ApiBaseResponse { Success = false, Message = "Chỉ hỗ trợ POST" }, 405).ConfigureAwait(false);
                return;
            }

            string body;
            using (var reader = new StreamReader(ctx.Request.InputStream))
                body = await reader.ReadToEndAsync().ConfigureAwait(false);

            Debug.WriteLine($"[ChatProxy] [ASK] IncomingBody={Trunc(body)}");

            AskRequest payload;
            try
            {
                payload = string.IsNullOrWhiteSpace(body)
                    ? new AskRequest { message = "" }
                    : JsonConvert.DeserializeObject<AskRequest>(body);
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[ChatProxy] [ASK] JSON parse error: {ex}");
                await WriteJson(ctx, new ApiBaseResponse { Success = false, Message = "Body không hợp lệ" }, 400).ConfigureAwait(false);
                return;
            }

            var chatService = new ChatService();
            var sw = Stopwatch.StartNew();
            Debug.WriteLine($"[ChatProxy] [ASK] -> ChatService.AskAsync('{Trunc(payload?.message, 200)}')");
            var result = await chatService.AskAsync(token, payload?.message).ConfigureAwait(false);
            sw.Stop();

            Debug.WriteLine($"[ChatProxy] [ASK] <- ChatService: Success={result?.Success} Code={result?.Code} Elapsed={sw.ElapsedMilliseconds}ms Reply={Trunc(result?.Reply)} Raw={Trunc(result?.RawBody)}");

            await WriteJson(ctx, result ?? new ChatAskResponse { Success = false, Message = "No response" },
                            result?.Success == true ? 200 : 400).ConfigureAwait(false);
        }

        private static Task WriteJson(HttpContext ctx, object obj, int statusCode = 200)
        {
            var json = JsonConvert.SerializeObject(obj, JsonSettings);
            ctx.Response.StatusCode = statusCode;
            ctx.Response.ContentType = "application/json; charset=utf-8";
            ctx.Response.Write(json);
            try { ctx.Response.Flush(); } catch { /* ignore */ }
            try { ctx.ApplicationInstance?.CompleteRequest(); } catch { /* ignore */ }

            Debug.WriteLine($"[ChatProxy] -> HTTP {statusCode} JSON={Trunc(json)}");
            return Task.CompletedTask;
        }

        public override bool IsReusable => false;
    }
}
