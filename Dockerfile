# Sử dụng image .NET SDK để build ứng dụng
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

# Đặt thư mục làm việc trong container
WORKDIR /src

# Sao chép toàn bộ mã nguồn vào container
COPY . .


RUN apt-get update && apt-get install -y openssl && \
    dotnet restore Acme.BookStore.sln && \
    dotnet build Acme.BookStore.sln -c Release -o /app/build && \
    dotnet publish Acme.BookStore.sln -c Release -o /app/publish

# Sử dụng image .NET Runtime để chạy ứng dụng
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final

# Đặt thư mục làm việc trong container
WORKDIR /app

# Sao chép các file đã build từ bước trước vào container
COPY --from=build /app/publish .

# Sao chép file chứng chỉ vào container (chú ý rằng đường dẫn có thể cần thay đổi)
COPY openiddict.pfx /app/

# Cấu hình quyền truy cập cho file chứng chỉ
RUN chmod 644 /app/openiddict.pfx

# Mở cổng mà ứng dụng sẽ lắng nghe
EXPOSE 5000
EXPOSE 8080

# Đảm bảo rằng ứng dụng có thể truy cập chứng chỉ khi cần
ENV ASPNETCORE_Kestrel__Certificates__Default__Password="123456"
ENV ASPNETCORE_Kestrel__Certificates__Default__Path="/app/openiddict.pfx"

# Chạy ứng dụng khi container được khởi động
ENTRYPOINT ["dotnet", "Acme.BookStore.Blazor.dll"]

