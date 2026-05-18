using WtcCrm.Domain.Entities;

namespace WtcCrm.Domain.Interfaces
{
    public interface ICustomerNoteRepository
    {
        Task CreateNoteAsync(CustomerNote note);
        Task<IEnumerable<CustomerNote>> GetNotesByCustomerIdAsync(string customerId);
        Task<CustomerNote?> GetNoteByIdAsync(string noteId);
        Task UpdateNoteAsync(CustomerNote note);
        Task DeleteNoteAsync(string noteId);
    
    }
}