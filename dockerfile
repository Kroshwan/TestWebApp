FROM microsoft/dotnet:sdk AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY **/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/dotnet:aspnetcore-runtime
WORKDIR /app

# Make port 80 available to the world outside this container
EXPOSE 80

COPY --from=build-env /app/TestWebApp/out .
ENTRYPOINT ["dotnet", "TestWebApp.dll"]