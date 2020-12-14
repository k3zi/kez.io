struct GithubWebhookObject: Decodable {

    struct Repo: Decodable {
        let id: Int
        let name: String
    }

    let repository: Repo

}
