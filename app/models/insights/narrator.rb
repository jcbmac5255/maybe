class Insights::Narrator
  CACHE_TTL = 6.hours

  def initialize(family, period)
    @family = family
    @period = period
  end

  def call
    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      generate
    end
  rescue => e
    Rails.logger.warn("Insights narrator failed: #{e.class}: #{e.message}")
    nil
  end

  private
    attr_reader :family, :period

    def cache_key
      [
        "insights_narrative",
        family.id,
        period.start_date,
        period.end_date,
        family.entries_cache_version
      ]
    end

    def generate
      provider = Provider::Registry.for_concept(:llm).providers.first
      return nil unless provider

      model = ENV.fetch("DEFAULT_AI_MODEL", "claude-haiku-4-5")
      response = provider.chat_response(
        prompt,
        model: model,
        instructions: instructions
      )
      return nil unless response.success?

      response.data.messages.map(&:output_text).join.strip.presence
    end

    def instructions
      <<~TXT
        You write short, friendly financial summaries for a household using Lumen, a personal finance app.
        Be specific with numbers. Mention notable categories, trends, or changes.
        Tone: casual, encouraging, factual. No fluff, no platitudes.
        Output: ONE paragraph, 2-4 sentences. No headings, no lists, no markdown.
      TXT
    end

    def prompt
      statement = family.income_statement
      income = statement.income_totals(period: period)
      expenses = statement.expense_totals(period: period)
      prior = prior_period
      prior_income = statement.income_totals(period: prior)
      prior_expenses = statement.expense_totals(period: prior)

      top_expenses = top_categories(expenses)
      top_income = top_categories(income)

      <<~PROMPT
        Currency: #{family.currency}.
        Period: #{period.start_date} to #{period.end_date} (#{(period.end_date - period.start_date).to_i + 1} days).
        Prior period: #{prior.start_date} to #{prior.end_date}.

        Totals this period:
          Income:   #{income.total}
          Expenses: #{expenses.total}
          Net:      #{income.total - expenses.total}

        Totals prior period:
          Income:   #{prior_income.total}
          Expenses: #{prior_expenses.total}
          Net:      #{prior_income.total - prior_expenses.total}

        Top 5 expense categories this period:
        #{top_expenses.map { |t| "  - #{t.category.name}: #{t.total}" }.join("\n")}

        Top 3 income categories this period:
        #{top_income.first(3).map { |t| "  - #{t.category.name}: #{t.total}" }.join("\n")}

        Write the summary now.
      PROMPT
    end

    def top_categories(period_total)
      period_total.category_totals
        .reject { |ct| ct.category.subcategory? || ct.total.zero? }
        .sort_by { |ct| -ct.total.to_f }
        .first(5)
    end

    def prior_period
      length = (period.end_date - period.start_date).to_i + 1
      Period.custom(
        start_date: period.start_date - length,
        end_date: period.start_date - 1
      )
    end
end
