public actor Root {
    public init() async {
        let core = await Core()
        let shell = await Shell()
        await shell.render(Rendition.navigate(.orderBook))
        Task {
            for await report in await core.run() {
                switch report {
                case let .rendition(r):
                    await shell.render(r)
                }
            }
        }
        Task {
            for await report in await shell.run() {
                switch report {
                case let .action(x):
                    await core.execute(x)
                }
            }
        }
    }
}

