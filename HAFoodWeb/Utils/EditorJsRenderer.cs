using System;
using System.Text;
using System.Web;
using Newtonsoft.Json.Linq;

namespace HAFoodWeb.Utils
{
    public static class EditorJsRenderer
    {
        public static string Render(string editorJson, Func<string, string> normalizeUrl = null)
        {
            if (string.IsNullOrWhiteSpace(editorJson)) return "";

            JObject root;
            try { root = JObject.Parse(editorJson); }
            catch { return ""; }

            var blocks = root["blocks"] as JArray;
            if (blocks == null || blocks.Count == 0) return "";

            var sb = new StringBuilder();

            foreach (var blk in blocks)
            {
                var type = (string)blk["type"];
                var data = blk["data"] as JObject;
                if (string.IsNullOrWhiteSpace(type) || data == null) continue;

                switch (type)
                {
                    case "header":
                        {
                            var text = (string)data["text"] ?? "";
                            var level = (int?)data["level"] ?? 2;
                            level = Math.Max(2, Math.Min(4, level));
                            sb.Append($"<h{level}>{H(text)}</h{level}>");
                            break;
                        }

                    case "paragraph":
                        {
                            var text = (string)data["text"] ?? "";
                            sb.Append("<p>").Append(H(text)).Append("</p>");
                            break;
                        }

                    case "list":
                        {
                            var style = (string)data["style"] ?? "unordered";
                            var tag = (style == "ordered") ? "ol" : "ul";
                            sb.Append("<").Append(tag).Append(">");

                            var items = data["items"] as JArray;
                            if (items != null)
                            {
                                foreach (var it in items)
                                {
                                    sb.Append("<li>").Append(H(it?.ToString() ?? "")).Append("</li>");
                                }
                            }

                            sb.Append("</").Append(tag).Append(">");
                            break;
                        }

                    case "quote":
                        {
                            var text = (string)data["text"] ?? "";
                            var cap = (string)data["caption"] ?? "";
                            sb.Append("<blockquote>").Append(H(text));
                            if (!string.IsNullOrWhiteSpace(cap))
                                sb.Append("<footer class='text-muted small mt-1'>").Append(H(cap)).Append("</footer>");
                            sb.Append("</blockquote>");
                            break;
                        }

                    case "delimiter":
                        sb.Append("<hr/>");
                        break;

                    case "image":
                        {
                            var url = (string)data["file"]?["url"] ?? (string)data["url"];
                            var cap = (string)data["caption"] ?? "";

                            if (!string.IsNullOrWhiteSpace(url))
                            {
                                if (normalizeUrl != null) url = normalizeUrl(url);

                                sb.Append("<figure>")
                                  .Append($"<img src=\"{HttpUtility.HtmlAttributeEncode(url)}\" alt=\"{HttpUtility.HtmlAttributeEncode(cap)}\"/>");

                                if (!string.IsNullOrWhiteSpace(cap))
                                    sb.Append($"<figcaption class='text-muted small mt-1'>{H(cap)}</figcaption>");

                                sb.Append("</figure>");
                            }
                            break;
                        }
                }
            }

            return sb.ToString();
        }

        // Encode an toàn (đảm bảo không XSS)
        private static string H(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return HttpUtility.HtmlEncode(s).Replace("\n", "<br/>");
        }
    }
}
