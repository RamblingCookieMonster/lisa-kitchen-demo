Deploy ExampleDeployment {
    By FileSystem {
        FromSource "$ENV:BHProjectPath"
        To 'C:\Project'
        Tagged Prod
    }

    By FileSystem {
        FromSource "$ENV:Temp\Kitchen\data"
        To 'C:\Project'
        Tagged Local
    }
}