public final class Root {
    let core = Core()
    let shell = Shell()
    public init() {
        shell.queue(Rendition.navigate(.orderBook))
        core.dispatch { [weak self] x in self?.shell.queue(x) }
        shell.dispatch { [weak self] x in self?.core.queue(x) }
    }
}
