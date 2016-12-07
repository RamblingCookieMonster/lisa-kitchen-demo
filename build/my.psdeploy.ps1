Deploy ExampleDeployment {
    By FileSystem {
        FromSource "$ENV:Temp\Kitchen\data"
        To 'C:\Project'
    }
}