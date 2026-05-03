// This file contains your Data Connector logic
[Version = "1.0.0"]
section MyConnectionSDK;

[DataSource.Kind="MyConnectionSDK", Publish="MyConnectionSDK.Publish"]
shared MyConnectionSDK.Contents = (optional message as text) =>
    let
        _message = if (message <> null) then message else "(no message)",
        a = "Hello from MyConnectionSDK: " & _message
    in
        a;

// Data Source Kind description
MyConnectionSDK = [
    Authentication = [
        // Key = [],
        // UsernamePassword = [],
        // Windows = [],
        Anonymous = []
    ]
];

// Data Source UI publishing description
MyConnectionSDK.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = MyConnectionSDK.Icons,
    SourceTypeImage = MyConnectionSDK.Icons
];

MyConnectionSDK.Icons = [
    Icon16 = { Extension.Contents("MyConnectionSDK16.png"), Extension.Contents("MyConnectionSDK20.png"), Extension.Contents("MyConnectionSDK24.png"), Extension.Contents("MyConnectionSDK32.png") },
    Icon32 = { Extension.Contents("MyConnectionSDK32.png"), Extension.Contents("MyConnectionSDK40.png"), Extension.Contents("MyConnectionSDK48.png"), Extension.Contents("MyConnectionSDK64.png") }
];
