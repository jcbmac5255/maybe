class Provider::Anthropic < Provider
  include LlmConcept

  Error = Class.new(Provider::Error)

  MODELS = %w[claude-opus-4-7 claude-opus-4-6 claude-sonnet-4-6 claude-haiku-4-5]

  def initialize(api_key)
    @client = ::Anthropic::Client.new(api_key: api_key)
  end

  def supports_model?(model)
    MODELS.include?(model)
  end

  def chat_response(prompt, model:, instructions: nil, functions: [], function_results: [], streamer: nil, previous_response_id: nil, chat: nil)
    with_provider_response do
      chat_config = ChatConfig.new(
        prompt: prompt,
        chat: chat,
        functions: functions,
        function_results: function_results
      )

      params = {
        model: model,
        max_tokens: 4096,
        messages: chat_config.messages,
        tools: chat_config.tools
      }
      params[:system] = instructions if instructions.present?
      params.delete(:tools) if params[:tools].empty?

      if streamer.present?
        run_streaming(params, streamer)
      else
        raw = client.messages.create(**params)
        ChatParser.new(raw).parsed
      end
    end
  end

  private
    attr_reader :client

    def run_streaming(params, streamer)
      stream = client.messages.stream(**params)
      parser = ChatStreamParser.new

      stream.each do |event|
        parser.push(event).each do |chunk|
          streamer.call(chunk)
        end
      end

      final_chunk = parser.finalize
      streamer.call(final_chunk)
      final_chunk.data
    end
end
