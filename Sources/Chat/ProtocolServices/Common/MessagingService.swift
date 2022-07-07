import Foundation
import WalletConnectUtils
import Combine

class MessagingService {
    let networkingInteractor: NetworkInteracting
    let messagesStore: CodableStore<Message>
    let logger: ConsoleLogging
    var onMessage: ((Message) -> Void)?
    private var publishers = [AnyCancellable]()

    init(networkingInteractor: NetworkInteracting,
         messagesStore: CodableStore<Message>,
         logger: ConsoleLogging) {
        self.networkingInteractor = networkingInteractor
        self.messagesStore = messagesStore
        self.logger = logger
        setUpResponseHandling()
        setUpRequestHandling()
    }

    func send(topic: String, messageString: String) async throws {
        //TODO - manage author account
        let authorAccount = "TODO"
        let message = Message(message: messageString, authorAccount: authorAccount, timestamp: JsonRpcID.generate())
        let request = JSONRPCRequest<ChatRequestParams>(params: .message(message))
        try await networkingInteractor.request(request, topic: topic, envelopeType: .type0)
    }

    private func setUpResponseHandling() {
        networkingInteractor.responsePublisher
            .sink { [unowned self] response in
                switch response.requestParams {
                case .message:
                    handleMessageResponse(response)
                default:
                    return
                }
            }.store(in: &publishers)
    }

    private func setUpRequestHandling() {
        networkingInteractor.requestPublisher.sink { [unowned self] subscriptionPayload in
            switch subscriptionPayload.request.params {
            case .message(let message):
                handleMessage(message)
            default:
                return
            }
        }.store(in: &publishers)
    }

    private func handleMessage(_ message: Message) {
        onMessage?(message)
        logger.debug("Received message")
    }

    private func handleMessageResponse(_ response: ChatResponse) {
        logger.debug("Received Message response")
    }
}
