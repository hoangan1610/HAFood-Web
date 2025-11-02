using System.Collections.Generic;
using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface IAddressService
    {
        Task<IReadOnlyList<AddressDto>> GetMyAddressesAsync(string token, bool onlyActive = true);
        Task<AddressDto> CreateAddressAsync(string token, AddressCreateRequest request);
        Task<AddressDto> UpdateAddressAsync(string token, long id, AddressUpdateRequest request);
        Task<bool> DeleteAddressAsync(string token, long id);
        Task<AddressDto> SetDefaultAsync(string token, long id);
        Task<AddressDto> GetMyAddressByIdAsync(string token, long id);
    }
}
