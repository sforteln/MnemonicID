## Mnemonic ID

### Purpose

While building systems that integrate with AIs, I noticed that they had real difficulty remembering UUIDs. When I asked the AI about this, it explained that random strings of letters and numbers, while very good at being unique, are hard for it to remember because they have no semantic meaning. So after some discussion, we came up with this system of IDs. The idea being that we use a combination of actual words as the ID; `far-swan`, for example. Words do have semantic meaning, so they are much easier to remember. And in my experience this has really helped the AIs ability to remember and correctly recall the IDs. 

### How it works

It's really simple. There is a list of ~7,500 words (you can configure it with your own word list if you want), and it picks randomly from it for each term in the ID. To remove the small risk that the AI might accidentally see `swan-swan` and collapse it to just `swan`, the library does not allow adjacent duplicates but does allow IDs like `swan-jump-swan`. 

This library does not in any way keep track of used IDs; that is the responsibility of the integrating app. With ~7,500 words and three terms, collisions should be rare. And you can reduce this by only assigning Mnemonic Ids to AI-facing data and internally using a traditional UUID. 

#### Prefixes

I've also added the ability to add an Entity-typed prefix to IDs. This is purely to assist the AI by adding additional context to the ID. So `far-swan` becomes `PRJ:far-swan` so the AI knows that this is an ID for a Project object with the ID far-swan. I don't store these and add/remove them at the MCP server barrier. 

### Usage

The Struct is marked `Sendable` so it is safe to use across concurrent tasks

#### Create and configure a mnemonic id vendor
``` swift
let vendor = MnemonicIDVendor(termsPerID: 3)
let id = vendor.createID()
```

#### Using prefixes
``` swift
var vendor = MnemonicIDVendor(termsPerID: 2)
vendor.register(Int.self, prefix: "INT")
let id = try vendor.createIDWithPrefix(Int.self)
```

#### Remove prefixes
``` swift
let vendor = MnemonicIDVendor(termsPerID: 2)
vendor.removePrefix("PRJ:far-swan")
```

#### Use a custom word list
``` swift
let words = ["alpha", "beta", "gamma"]
let vendor = MnemonicIDVendor(wordList: words, termsPerID: 2)
let id = vendor.createID()
```

### Install
In Xcode, select `File > Swift Packages > Add Package Dependency...`

Enter the repository URL: `https://github.com/simonfortelny/MnemonicId`

Or add it directly to your `Package.swift`:
``` swift
dependencies: [
    .package(url: "https://github.com/simonfortelny/MnemonicId", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["MnemonicID"]
    )
]
```

### License
This repository is licensed under the MIT license. See the [LICENSE](./LICENSE) file for more information.

