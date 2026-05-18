using Microsoft.EntityFrameworkCore;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Infrastructure.Data;

namespace WtcCrm.Infrastructure.Repositories
{
    public class UserRepository(AppDbContext _context) : IUserRepository
    {
        public async Task<User?> GetByEmailAsync(string email)
            => await _context.Users.FirstOrDefaultAsync(a => a.Email == email);
            
        public async Task<User?> GetByDocumentIdAsync(string documentId) 
            => await _context.Users.FirstOrDefaultAsync(a => a.DocumentId == documentId);
        
        public async Task<User?> GetByIdAsync(string userId)
            => await _context.Users.FirstOrDefaultAsync(a => a.Id == Guid.Parse(userId));

        public async Task AddAsync(User user)
        {
            await _context.Users.AddAsync(user);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(User user)
        {
            _context.Users.Update(user);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateUserImageAsync(string userId, string imageKey)
        {
            var user = await _context.Users.FirstOrDefaultAsync(a => a.Id == Guid.Parse(userId));
            if (user != null)
            {
                user.ProfileImageKey = imageKey;
                _context.Users.Update(user);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<User>> SearchUsersByRoleAsync(string role, string? search)
        {
            var query = _context.Users.AsQueryable();

            if (!string.IsNullOrEmpty(role))
            {
                if (Enum.TryParse<UserRole>(role, true, out var userRole))
                {
                    query = query.Where(a => a.Role == userRole);
                }
                else
                {
                    return Enumerable.Empty<User>();
                }
            }

            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(a => a.Name.Contains(search) || a.Email.Contains(search));
            }
            else
            {
                query = query.Take(50);
            }

            return await query.ToListAsync();
        }

        public async Task<IEnumerable<User>> GetAllActiveUsersAsync()
        {
            return await _context.Users
                .Where(a => a.Role == UserRole.User) 
                .ToListAsync();
        }

        public async Task<IEnumerable<User>> GetUsersByIdsAsync(IEnumerable<string> userIds)
        {
            var guidIds = userIds.Select(id => Guid.Parse(id)).ToList();

            return await _context.Users
                .Where(a => guidIds.Contains(a.Id))
                .ToListAsync();
        }

        public async Task<IEnumerable<User>> SearchCustomersAsync(string? query, string? status, int page, int pageSize)
        {
            var queryable = _context.Users.AsQueryable();

            if (!string.IsNullOrWhiteSpace(query))
            {
                queryable = queryable.Where(a => a.Name.Contains(query) || a.Email.Contains(query));
            }

            if (!string.IsNullOrWhiteSpace(status))
            {
                queryable = queryable.Where(a => a.Status == status);
            }

            var allowedRoles = new[] { UserRole.User, UserRole.Customer };
            queryable = queryable.Where(a => allowedRoles.Contains(a.Role));

            int skip = (page - 1) * pageSize;

            return await queryable
                .OrderByDescending(a => a.Score)
                .Skip(skip)
                .Take(pageSize)
                .ToListAsync();
        }
    }
}