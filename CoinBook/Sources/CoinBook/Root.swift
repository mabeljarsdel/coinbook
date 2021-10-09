public actor Root {
    public init() async {
        let core = await Core()
        let shell = await Shell()
        let actions = Chan<Action>()
        let renditions = Chan<Rendition>()
        await renditions <- Rendition.navigate(.orderBook)
        Task {
            for await report in await core.run(actions: actions) {
                switch report {
                case let .rendition(r):
                    await renditions <- r
                }
            }
        }
        Task {
            for await x in await shell.run(with: renditions) {
                await actions <- x
            }
        }
    }
}
