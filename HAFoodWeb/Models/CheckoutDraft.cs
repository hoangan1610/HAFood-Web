using System;

namespace HAFoodWeb.Models
{
    public sealed class CheckoutDraftItem
    {
        public long VariantId { get; set; }
        public int Quantity { get; set; }
        public string ProductName { get; set; }
        public string VariantName { get; set; }
        public string ImageUrl { get; set; }
        public decimal Price { get; set; }
    }

    public sealed class CheckoutDraft
    {
        public string ShipName { get; set; }
        public string ShipPhone { get; set; }
        public string ShipAddress { get; set; }
        public string PromoCode { get; set; }
        public string Note { get; set; }
        public long[] SelectedLineIds { get; set; }
        public (long variant_Id, int quantity)[] Items { get; set; }
        public string DeviceUuid { get; set; }
        public string CityCode { get; set; }
        public string WardCode { get; set; }

        // ✅ NEW: tổng khối lượng (gram)
        public int TotalWeightGram { get; set; }

        public CheckoutDraftItem[] Snapshot { get; set; }
        public decimal SnapshotSubtotal { get; set; }
        public decimal SnapshotVat { get; set; }
        public decimal SnapshotShipping { get; set; }
        public decimal SnapshotGrand { get; set; }

        public decimal SnapshotDiscount { get; set; }
    }


}
