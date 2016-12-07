Deploy ExampleDeployment {
    By FileSystem prod {
        FromSource "C:\projects\lisa-kitchen-demo"
        To 'C:\Project'
        Tagged Prod
    }

    By FileSystem local {
        FromSource "$ENV:Temp\Kitchen\data"
        To 'C:\Project'
        Tagged Local
    }
}