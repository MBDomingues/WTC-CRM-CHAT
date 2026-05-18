namespace WtcCrm.Application.Wrappers
{
    public class BaseResponse<T>
    {
        public bool IsSuccess { get; private set; }
        public T? Content { get; private set; }
        public string? ErrorMessage { get; private set; }

        private BaseResponse(bool isSuccess, T? content, string? errorMessage)
        {
            IsSuccess = isSuccess;
            Content = content;
            ErrorMessage = errorMessage;
        }

        public static BaseResponse<T> Success(T content)
        {
            return new BaseResponse<T>(true, content, null);
        }

        public static BaseResponse<T> Error(string errorMessage)
        {
            return new BaseResponse<T>(false, default, errorMessage);
        }
    }
}
