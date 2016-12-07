Deploy ExampleDeployment {
    By FileSystem prod {
        FromSource "$ENV:BHProjectPath"
        To 'C:\Project'
        Tagged Prod
    }

    By FileSystem local {
        FromSource "$ENV:Temp\Kitchen\data"
        To 'C:\Project'
        Tagged Local
    }
}