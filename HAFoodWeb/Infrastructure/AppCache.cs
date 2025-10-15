using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.Caching;

namespace HAFoodWeb.Infrastructure
{
    public static class AppCache
    {
        private static Cache Cache => HttpRuntime.Cache;

        public static T GetOrAdd<T>(string key, Func<T> factory, int seconds)
        {
            var item = Cache.Get(key);
            if (item is T ok) return ok;

            var value = factory();
            if (value != null)
            {
                Cache.Insert(
                    key,
                    value,
                    dependencies: null,
                    absoluteExpiration: DateTime.UtcNow.AddSeconds(seconds),
                    slidingExpiration: Cache.NoSlidingExpiration
                );
            }
            return value;
        }

        public static async Task<T> GetOrAddAsync<T>(string key, Func<Task<T>> factory, int seconds)
        {
            var item = Cache.Get(key);
            if (item is T ok) return ok;

            var value = await factory();
            if (value != null)
            {
                Cache.Insert(
                    key,
                    value,
                    dependencies: null,
                    absoluteExpiration: DateTime.UtcNow.AddSeconds(seconds),
                    slidingExpiration: Cache.NoSlidingExpiration
                );
            }
            return value;
        }

        public static void Remove(string key) => Cache.Remove(key);
    }
}
