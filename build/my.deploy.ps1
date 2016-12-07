Deploy ExampleDeployment {
    By FileSystem {
        FromSource "$ENV\Kitchen\data"
        To 'C:\Project'
    }
}