class Provider::Anthropic::ChatParser
  ChatResponse = Provider::LlmConcept::ChatResponse
  ChatMessage = Provider::LlmConcept::ChatMessage
  ChatFunctionRequest = Provider::LlmConcept::ChatFunctionRequest

  def initialize(message)
    @message = message
  end

  def parsed
    ChatResponse.new(
      id: message.id,
      model: message.model,
      messages: build_messages,
      function_requests: build_function_requests
    )
  end

  private
    attr_reader :message

    def build_messages
      text = text_from_blocks(message.content)
      return [] if text.blank?

      [ ChatMessage.new(id: message.id, output_text: text) ]
    end

    def build_function_requests
      message.content.select { |b| block_type(b) == "tool_use" }.map do |block|
        input = block_field(block, :input) || {}
        ChatFunctionRequest.new(
          id: block_field(block, :id),
          call_id: block_field(block, :id),
          function_name: block_field(block, :name),
          function_args: input.is_a?(String) ? input : input.to_json
        )
      end
    end

    def text_from_blocks(blocks)
      blocks.select { |b| block_type(b) == "text" }.map { |b| block_field(b, :text) }.join
    end

    def block_type(block)
      block.respond_to?(:type) ? block.type.to_s : block[:type].to_s
    end

    def block_field(block, key)
      if block.respond_to?(key)
        block.public_send(key)
      else
        block[key] || block[key.to_s]
      end
    end
end
