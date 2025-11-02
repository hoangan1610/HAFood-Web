using System;
using System.Collections.Generic;

namespace HAFoodWeb.Models
{
    public class ApiEnvelope<T>
    {
        public bool success { get; set; }
        public T data { get; set; }
        public string message { get; set; }
    }

    public class AddressDto
    {
        public long id { get; set; }
        public long userInfoId { get; set; }
        public int? type { get; set; }               
        public string label { get; set; }            
        public bool isDefault { get; set; }
        public string fullName { get; set; }         
        public string phone { get; set; }            
        public int status { get; set; }
        public string fullAddress { get; set; }
        public DateTime createdAt { get; set; }
        public DateTime updatedAt { get; set; }
    }

    public class AddressCreateRequest
    {
        public int? type { get; set; }               
        public string label { get; set; }            
        public bool isDefault { get; set; }
        public string fullName { get; set; }         
        public string phone { get; set; }            
        public string fullAddress { get; set; }
    }

    public class AddressUpdateRequest
    {
        public int? type { get; set; }               
        public string label { get; set; }            
        public bool? isDefault { get; set; }         
        public string fullName { get; set; }         
        public string phone { get; set; }            
        public string fullAddress { get; set; }      
        public int? status { get; set; }             
    }

    public class AddressDtoApiOkResponse
    {
        public bool success { get; set; }
        public AddressDto data { get; set; }
        public string message { get; set; }
    }

    public class AddressDtoIReadOnlyListApiOkResponse
    {
        public bool success { get; set; }
        public List<AddressDto> data { get; set; }   
        public string message { get; set; }
    }
}
