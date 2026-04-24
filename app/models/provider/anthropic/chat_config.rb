class Provider::Anthropic::ChatConfig
  def initialize(prompt:, chat: nil, functions: [], function_results: [])
    @prompt = prompt
    @chat = chat
    @functions = functions
    @function_results = function_results
  end

  def tools
    functions.map do |fn|
      {
        name: fn[:name],
        description: fn[:description],
        input_schema: fn[:params_schema]
      }
    end
  end

  def messages
    history = build_history

    if function_results.any?
      history << {
        role: "user",
        content: function_results.map do |r|
          {
            type: "tool_result",
            tool_use_id: r[:call_id],
            content: r[:output].to_json
          }
        end
      }
    elsif history.empty? || history.last[:role] != "user"
      history << { role: "user", content: prompt }
    end

    history
  end

  private
    attr_reader :prompt, :chat, :functions, :function_results

    def build_history
      return [] if chat.nil?

      chat.messages.ordered.each_with_object([]) do |msg, acc|
        case msg
        when UserMessage
          acc << { role: "user", content: msg.content }
        when AssistantMessage
          next if msg.content.blank? && msg.tool_calls.empty?
          blocks = []
          blocks << { type: "text", text: msg.content } if msg.content.present?
          msg.tool_calls.each do |tc|
            next unless tc.is_a?(ToolCall::Function)
            blocks << {
              type: "tool_use",
              id: tc.provider_id,
              name: tc.function_name,
              input: JSON.parse(tc.function_arguments.presence || "{}")
            }
          end
          acc << { role: "assistant", content: blocks } if blocks.any?
        end
      end
    end
end
