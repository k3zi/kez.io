struct GithubWebhookObject: Decodable {

    struct Hook: Decodable  {

        struct Config: Decodable  {
            let secret: String
        }

        let id: Int
        let active: Bool
        let config: Config

    }

    struct Repo: Decodable {
        let id: Int
        let name: String
    }

    let hook: Hook
    let repository: Repo

}
